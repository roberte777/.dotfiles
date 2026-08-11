#!/usr/bin/env bash
#
# Checks the failure modes that "is the container running?" monitoring misses.
#
# Every check in here corresponds to a state where docker reports every
# container up and healthy while the stack is in fact broken. Plain liveness
# probes belong in Uptime Kuma; this script is only for the silent failures.
#
# Sends one aggregated ntfy push per run when something is wrong, rather than
# one per check -- a gluetun outage trips several checks at once and separate
# messages would bury the useful one.
#
# Exit status is 0 when everything passes and 1 when any check fails, so the
# systemd unit's own status reflects stack health too.

set -uo pipefail

ENV_FILE="/home/theater/.dotfiles/nix/hosts/theater/.env"

# Read values out of .env without sourcing it -- the file contains comments with
# apostrophes and bare words that a shell would try to execute.
env_get() {
  local key="$1"
  sed -n "s/^${key}=//p" "$ENV_FILE" | head -n1
}

NTFY_URL="$(env_get NTFY_URL)"
NTFY_TOPIC="$(env_get NTFY_TOPIC)"
: "${NTFY_URL:=http://127.0.0.1:8085}"

# Collected failure lines; a non-empty array means we notify.
FAILURES=()
fail() { FAILURES+=("$1"); }

# Wrapper so a hung container command cannot wedge the whole run. Docker exec
# has no built-in timeout and gluetun's network can black-hole requests when the
# tunnel is down, which is exactly when this script needs to still finish.
dex() {
  timeout 20 docker exec "$@" 2>/dev/null
}

container_up() {
  [ "$(docker inspect -f '{{.State.Running}}' "$1" 2>/dev/null)" = "true" ]
}

# ---------------------------------------------------------------------------
# 1. gluetun is up at all. Everything below depends on it, so if this fails we
#    skip the tunnel-dependent checks rather than emitting a cascade of
#    confusing secondary failures.
# ---------------------------------------------------------------------------
GLUETUN_OK=false
if container_up gluetun; then
  GLUETUN_OK=true
else
  fail "gluetun is not running -- every download/indexer service is offline"
fi

if [ "$GLUETUN_OK" = true ]; then

  # -------------------------------------------------------------------------
  # 2. VPN leak check. If the tunnel drops but containers keep running, traffic
  #    could egress from the house IP. Compare the exit IP seen inside gluetun's
  #    namespace against the host's WAN IP; they must differ.
  #
  #    A lookup failure is NOT treated as a leak -- no answer means the tunnel
  #    is likely down (caught below), and calling that a leak would cry wolf.
  # -------------------------------------------------------------------------
  VPN_IP="$(dex gluetun wget -qO- --timeout=10 https://api.ipify.org | tr -d '[:space:]')"
  HOST_IP="$(curl -s --max-time 10 https://api.ipify.org | tr -d '[:space:]')"

  if [ -z "$VPN_IP" ]; then
    fail "gluetun cannot reach the internet -- tunnel is probably down"
  elif [ -n "$HOST_IP" ] && [ "$VPN_IP" = "$HOST_IP" ]; then
    fail "VPN LEAK: gluetun exit IP ($VPN_IP) equals the house WAN IP"
  fi

  # -------------------------------------------------------------------------
  # 3. Forwarded port exists AND qBittorrent knows about it.
  #
  #    Two distinct failures share this check:
  #      - gluetun picked a server without port forwarding, so there is no port
  #      - gluetun got a port but VPN_PORT_FORWARDING_UP_COMMAND failed to push
  #        it into qBittorrent, leaving the client listening on a stale one
  #
  #    Reads /tmp/gluetun/forwarded_port rather than the control server API:
  #    the API requires auth config, the file does not, and gluetun writes it on
  #    every port acquisition.
  # -------------------------------------------------------------------------
  FWD_PORT="$(dex gluetun cat /tmp/gluetun/forwarded_port | tr -d '[:space:]')"

  if [ -z "$FWD_PORT" ] || [ "$FWD_PORT" = "0" ]; then
    fail "No forwarded port from Proton -- torrents will not be connectable"
  else
    # qBittorrent's own view. Relies on "Bypass authentication for clients on
    # localhost" being enabled, same as the gluetun up-command does.
    QB_PREFS="$(dex gluetun wget -qO- --timeout=10 http://127.0.0.1:8084/api/v2/app/preferences)"
    if [ -z "$QB_PREFS" ]; then
      fail "qbittorrent-mam WebUI is not responding on 8084"
    else
      QB_PORT="$(printf '%s' "$QB_PREFS" | tr ',' '\n' | sed -n 's/.*"listen_port":\([0-9]*\).*/\1/p' | head -n1)"
      if [ "$QB_PORT" != "$FWD_PORT" ]; then
        fail "Port mismatch: Proton forwarded $FWD_PORT but qbittorrent-mam listens on ${QB_PORT:-unknown} -- the up-command did not apply"
      fi
    fi
  fi

  # -------------------------------------------------------------------------
  # 4. MAM session health.
  #
  #    MouseHole's /health returns HTTP 200 even when MAM is actively rejecting
  #    the session, so an HTTP-status monitor shows green through a total
  #    outage. The JSON body is the only signal that matters.
  # -------------------------------------------------------------------------
  MH_HEALTH="$(dex gluetun wget -qO- --timeout=10 http://127.0.0.1:5010/health)"
  if [ -z "$MH_HEALTH" ]; then
    fail "MouseHole is not responding on 5010"
  elif ! printf '%s' "$MH_HEALTH" | grep -q '"lastMamContactResult":"ok"'; then
    MH_RESULT="$(printf '%s' "$MH_HEALTH" | sed -n 's/.*"lastMamContactResult":"\([^"]*\)".*/\1/p')"
    fail "MAM session is ${MH_RESULT:-unknown} -- qbittorrent-mam will be rejected by the tracker"
  fi

  # -------------------------------------------------------------------------
  # 5. qbittorrent-mam version is still inside MAM's allowed range (5.0.1
  #    through 5.2.x). The image tag is pinned and watchtower is told to skip
  #    this container, but this catches a manual bump or a label that stopped
  #    being honoured -- the symptom is otherwise a silent "Unauthorized
  #    Client".
  # -------------------------------------------------------------------------
  QB_VER="$(dex gluetun wget -qO- --timeout=10 http://127.0.0.1:8084/api/v2/app/version | tr -d '[:space:]v')"
  if [ -n "$QB_VER" ]; then
    QB_MAJOR="${QB_VER%%.*}"
    QB_REST="${QB_VER#*.}"
    QB_MINOR="${QB_REST%%.*}"
    if [ "$QB_MAJOR" != "5" ] || [ "$QB_MINOR" -gt 2 ] 2>/dev/null; then
      fail "qbittorrent-mam is on $QB_VER -- outside MAM's allowed 5.0.1-5.2.x range"
    fi
  fi
fi

# ---------------------------------------------------------------------------
# 6. Storage. mergerfs keeps serving reads from the remaining branches when a
#    bay unmounts, so a missing drive is invisible until files are.
#
#    Counts real mountpoints under /mnt/bay* and compares against the expected
#    count. Update EXPECTED_BAYS when adding a drive -- a hardcoded number is
#    the point, since deriving it from what is mounted would make a missing bay
#    define itself away.
# ---------------------------------------------------------------------------
EXPECTED_BAYS=1
MOUNTED_BAYS=0
for bay in /mnt/bay*; do
  [ -d "$bay" ] || continue
  if mountpoint -q "$bay"; then
    MOUNTED_BAYS=$((MOUNTED_BAYS + 1))
  else
    fail "$bay exists but is NOT mounted -- mergerfs is silently serving an incomplete pool"
  fi
done

if [ "$MOUNTED_BAYS" -lt "$EXPECTED_BAYS" ]; then
  fail "Only $MOUNTED_BAYS of $EXPECTED_BAYS bay drives are mounted"
fi

if ! mountpoint -q /mnt/storage; then
  fail "/mnt/storage (mergerfs pool) is not mounted"
else
  USE_PCT="$(df --output=pcent /mnt/storage 2>/dev/null | tail -n1 | tr -dc '0-9')"
  if [ -n "$USE_PCT" ] && [ "$USE_PCT" -ge 90 ]; then
    fail "Storage pool is ${USE_PCT}% full"
  fi
fi

# ---------------------------------------------------------------------------
# 7. Drive health. A failing disk in a single-bay pool takes the library with
#    it, so this watches the SMART attributes that actually predict failure
#    rather than the overall pass/fail verdict, which stays PASSED until very
#    late.
# ---------------------------------------------------------------------------
if command -v smartctl >/dev/null 2>&1; then
  for disk in /dev/sd?; do
    [ -b "$disk" ] || continue
    SMART="$(timeout 30 smartctl -A -H "$disk" 2>/dev/null)" || continue
    [ -n "$SMART" ] || continue

    if printf '%s' "$SMART" | grep -qE "SMART overall-health.*(FAILED|FAILING)"; then
      fail "SMART overall health FAILED on $disk -- replace this drive"
    fi

    # Reallocated and pending sectors are the leading indicators; any non-zero
    # value is worth knowing about on a drive holding the only copy.
    for attr in Reallocated_Sector_Ct Current_Pending_Sector Offline_Uncorrectable; do
      RAW="$(printf '%s' "$SMART" | awk -v a="$attr" '$2 == a {print $10; exit}')"
      if [ -n "$RAW" ] && [ "$RAW" -gt 0 ] 2>/dev/null; then
        fail "$disk has $RAW $attr -- drive is degrading"
      fi
    done
  done
fi

# ---------------------------------------------------------------------------
# Report. One message, all failures, so the phone shows a single actionable
# alert instead of a burst.
# ---------------------------------------------------------------------------
if [ "${#FAILURES[@]}" -eq 0 ]; then
  echo "OK: all checks passed"
  exit 0
fi

BODY="$(printf '%s\n' "${FAILURES[@]}")"
echo "FAILURES:"
echo "$BODY"

if [ -n "$NTFY_TOPIC" ]; then
  curl -s --max-time 20 \
    -H "Title: Theater: ${#FAILURES[@]} check(s) failing" \
    -H "Priority: high" \
    -H "Tags: rotating_light" \
    -d "$BODY" \
    "${NTFY_URL}/${NTFY_TOPIC}" >/dev/null 2>&1 \
    || echo "WARNING: could not reach ntfy at $NTFY_URL"
else
  echo "WARNING: NTFY_TOPIC not set in $ENV_FILE -- no notification sent"
fi

exit 1
