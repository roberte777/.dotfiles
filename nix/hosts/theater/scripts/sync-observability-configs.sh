#!/usr/bin/env bash
# Copies the observability config files out of /docker/appdata and into the
# repo, so a rebuild is not dependent on this machine's disk surviving.
#
# make_dirs.sh creates the directories; these are the files that go in them.
# Loki, Alloy and Prometheus do not start at all without their config, and
# Grafana comes up with no datasources, dashboards or alert rules -- a state
# that looks like a working install until you notice everything is empty.
#
# The ntfy contact point is deliberately NOT copied: it embeds NTFY_TOPIC, the
# only secret on an unauthenticated ntfy instance. A .example is written
# instead, with the topic replaced by a placeholder.
#
# Run after changing any of these files. `--check` compares without writing and
# exits non-zero if the repo is stale -- useful before a commit.

set -euo pipefail

APPDATA="${APPDATA_DIR:-/docker/appdata}"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="${REPO}/observability"

CHECK=0
[ "${1:-}" = "--check" ] && CHECK=1

# src (relative to APPDATA) -> dest (relative to DEST)
FILES="
loki/loki-config.yaml|loki/loki-config.yaml
alloy/config.alloy|alloy/config.alloy
prometheus/prometheus.yml|prometheus/prometheus.yml
grafana/provisioning/datasources/loki.yaml|grafana/provisioning/datasources/loki.yaml
grafana/provisioning/datasources/prometheus.yaml|grafana/provisioning/datasources/prometheus.yaml
grafana/provisioning/dashboards/media-stack.yaml|grafana/provisioning/dashboards/media-stack.yaml
grafana/provisioning/alerting/rules.yaml|grafana/provisioning/alerting/rules.yaml
grafana/provisioning/alerting/rules-resources.yaml|grafana/provisioning/alerting/rules-resources.yaml
"

# Dashboard JSON is deliberately NOT synced. It is the one part of this setup
# that is cheap to rebuild and annoying to keep in sync -- panel layout churns
# whenever it is edited in the UI, and a stale copy in the repo is worse than
# no copy. The queries that matter are documented in README.md instead.

STALE=0

for entry in $FILES; do
  [ -n "$entry" ] || continue
  src="${APPDATA}/${entry%%|*}"
  dst="${DEST}/${entry##*|}"

  if [ ! -f "$src" ]; then
    echo "  MISSING ON DISK: $src"
    STALE=1
    continue
  fi

  if [ "$CHECK" = "1" ]; then
    if ! cmp -s "$src" "$dst" 2>/dev/null; then
      echo "  STALE: ${entry##*|}"
      STALE=1
    fi
  else
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "  copied: ${entry##*|}"
  fi
done

# Contact point, with the topic stripped. Handled separately from the loop
# because it is the one file that must never land in git as-is.
CP_SRC="${APPDATA}/grafana/provisioning/alerting/contact-points.yaml"
CP_DST="${DEST}/grafana/provisioning/alerting/contact-points.yaml.example"
if [ -f "$CP_SRC" ]; then
  if [ "$CHECK" = "1" ]; then
    if ! sed -E 's#(url: http://ntfy:8085/).*#\1REPLACE_WITH_NTFY_TOPIC#' "$CP_SRC" | cmp -s - "$CP_DST" 2>/dev/null; then
      echo "  STALE: contact-points.yaml.example"
      STALE=1
    fi
  else
    mkdir -p "$(dirname "$CP_DST")"
    sed -E 's#(url: http://ntfy:8085/).*#\1REPLACE_WITH_NTFY_TOPIC#' "$CP_SRC" > "$CP_DST"
    echo "  copied: contact-points.yaml.example (topic redacted)"
  fi
fi

if [ "$CHECK" = "1" ]; then
  if [ "$STALE" = "1" ]; then
    echo "Repo copies are out of date -- run without --check."
    exit 1
  fi
  echo "All observability configs match the repo."
fi
