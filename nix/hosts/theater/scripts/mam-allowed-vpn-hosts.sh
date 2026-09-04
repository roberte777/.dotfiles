#!/usr/bin/env bash
# Re-derive the SERVER_HOSTNAMES pin for gluetun in docker-compose.yaml.
#
# Why this exists: MyAnonaMouse binds a seedbox session to a set of ASNs. Proton's
# US port-forward pool spans several transit providers, so an unpinned gluetun can
# reconnect onto an ASN the session does not allow and MAM starts answering every
# update with "403 Invalid session - ASN mismatch" until the IP is re-added by hand.
#
# This resolves every US port-forward endpoint Proton currently advertises, looks up
# the ASN each one exits from, and prints the subset that the MAM session already
# allows -- formatted as a ready-to-paste SERVER_HOSTNAMES value.
#
# Run it when MAM starts rejecting again (Proton renumbers nodes periodically), or
# after changing the allowed-ASN list on the MAM site.
#
# Usage:
#   scripts/mam-allowed-vpn-hosts.sh                 # use ALLOWED_ASNS below
#   ALLOWED_ASNS="9009,60068" scripts/mam-allowed-vpn-hosts.sh
#
# Requires: a running gluetun container (it supplies both the server list and the
# lookups, so the queries exit via the VPN rather than the host's own address).

set -euo pipefail

# ASNs currently authorised on the MAM session. Keep in sync with the allow-list
# shown under the seedbox settings on the MAM site.
ALLOWED_ASNS="${ALLOWED_ASNS:-9009,60068,63023,199218,208172}"

CONTAINER="${CONTAINER:-gluetun}"
COUNTRY="${COUNTRY:-United States}"

if ! docker inspect -f '{{.State.Running}}' "$CONTAINER" >/dev/null 2>&1; then
  echo "error: container '$CONTAINER' is not running" >&2
  exit 1
fi

# Build an ERE alternation like: AS(9009|60068|63023)
asn_pattern="AS($(printf '%s' "$ALLOWED_ASNS" | tr -d ' ' | tr ',' '|')) "

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

echo "Reading Proton server list from $CONTAINER..." >&2
docker exec "$CONTAINER" cat /gluetun/servers.json \
  | jq -r --arg c "$COUNTRY" '
      .protonvpn.servers
      | map(select(.country == $c and .port_forward == true))
      | unique_by(.hostname)
      | .[].hostname' \
  > "$workdir/hosts.txt"

total_hosts=$(wc -l < "$workdir/hosts.txt")
echo "Found $total_hosts port-forward endpoints in '$COUNTRY'. Resolving..." >&2

# Resolve inside the container: these hostnames are served by Proton's DNS.
docker cp "$workdir/hosts.txt" "$CONTAINER:/tmp/mam_hosts.txt" >/dev/null
docker exec "$CONTAINER" sh -c '
  while read -r h; do
    ip=$(nslookup "$h" 2>/dev/null | sed -n "s/^Address: *\([0-9.]*\)$/\1/p" | tail -1)
    [ -n "$ip" ] && echo "$h $ip"
  done < /tmp/mam_hosts.txt' > "$workdir/resolved.txt" || true
docker exec "$CONTAINER" rm -f /tmp/mam_hosts.txt >/dev/null 2>&1 || true

echo "Resolved $(wc -l < "$workdir/resolved.txt") hosts. Looking up ASNs (this takes a minute)..." >&2

: > "$workdir/asn_map.txt"
while read -r host ip; do
  org=$(docker exec "$CONTAINER" \
          sh -c "wget -qO- --timeout=8 https://ipinfo.io/$ip/org" 2>/dev/null \
        | tr -d '\r\n')
  printf '%s\t%s\t%s\n' "$host" "$ip" "${org:-UNKNOWN}" >> "$workdir/asn_map.txt"
done < "$workdir/resolved.txt"

echo >&2
echo "=== ASN distribution across the pool ===" >&2
cut -f3 "$workdir/asn_map.txt" | sort | uniq -c | sort -rn >&2

# Flag the ASNs carrying nodes that the session would reject.
echo >&2
echo "=== NOT authorised on the MAM session ===" >&2
if grep -vE "$asn_pattern" "$workdir/asn_map.txt" | cut -f3 | sort | uniq -c | sort -rn >&2; then :; fi

allowed="$(grep -E "$asn_pattern" "$workdir/asn_map.txt" || true)"
allowed_count=$(printf '%s' "$allowed" | grep -c . || true)

if [ "$allowed_count" -eq 0 ]; then
  echo >&2
  echo "error: no endpoints matched the allowed ASNs ($ALLOWED_ASNS)." >&2
  echo "Check the allow-list on the MAM site, or widen COUNTRY." >&2
  exit 1
fi

echo >&2
echo "=== $allowed_count usable endpoints, by ASN ===" >&2
printf '%s\n' "$allowed" | awk -F'\t' '{print $3"\t"$1}' | sort >&2

echo >&2
echo "Paste this into the gluetun service in docker-compose.yaml:" >&2
echo >&2
printf -- '      - SERVER_HOSTNAMES=%s\n' \
  "$(printf '%s\n' "$allowed" | cut -f1 | sort | paste -sd, -)"
