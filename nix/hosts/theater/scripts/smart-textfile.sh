#!/usr/bin/env bash
# Writes SMART attributes as Prometheus metrics for node-exporter's textfile
# collector.
#
# Why this exists: hwmon does not expose SATA drive temperature. On this box
# node_hwmon_temp_celsius covers the CPU package, NVMe, wifi and a thermal
# zone -- everything EXCEPT the 16TB spinner that holds the library. Its
# temperature and reallocated-sector counts are only readable over SMART, which
# needs root, so node-exporter (running unprivileged in a container) cannot get
# them itself.
#
# stack-healthcheck.sh already alerts on SMART *failure*. This is the trend
# view: a reallocated sector count creeping 0 -> 3 -> 9 over a month is the
# early warning that a pass/fail verdict cannot express.
#
# Output goes to a .prom file that node-exporter reads on each scrape. Written
# to a temp file and moved into place because node-exporter will happily read a
# half-written file and emit a parse error.

set -uo pipefail

TEXTFILE_DIR="/var/lib/node-exporter/textfile"
OUT="${TEXTFILE_DIR}/smart.prom"
TMP="${OUT}.$$"

mkdir -p "$TEXTFILE_DIR"

{
  echo "# HELP smartctl_device_temperature Drive temperature in celsius from SMART."
  echo "# TYPE smartctl_device_temperature gauge"
  echo "# HELP smartctl_device_reallocated_sectors Reallocated sector count -- a leading indicator of drive failure."
  echo "# TYPE smartctl_device_reallocated_sectors gauge"
  echo "# HELP smartctl_device_pending_sectors Current pending sector count."
  echo "# TYPE smartctl_device_pending_sectors gauge"
  echo "# HELP smartctl_device_power_on_hours Power-on hours."
  echo "# TYPE smartctl_device_power_on_hours gauge"
  echo "# HELP smartctl_device_health_ok 1 if SMART overall health is PASSED, 0 otherwise."
  echo "# TYPE smartctl_device_health_ok gauge"

  # Only real block devices; skip partitions, loop and zram.
  for dev in /dev/sd? /dev/nvme?n?; do
    [ -e "$dev" ] || continue
    name="$(basename "$dev")"

    ATTRS="$(smartctl -A -H "$dev" 2>/dev/null)" || continue
    [ -n "$ATTRS" ] || continue

    # Overall health verdict. Stays PASSED until very late, which is exactly why
    # the attributes below matter more -- but a FAILED here is unambiguous.
    if printf '%s' "$ATTRS" | grep -qE "(SMART overall-health|SMART Health Status).*(PASSED|OK)"; then
      echo "smartctl_device_health_ok{device=\"${name}\"} 1"
    else
      echo "smartctl_device_health_ok{device=\"${name}\"} 0"
    fi

    # Temperature. SATA reports it as attribute 194 (column 10); NVMe uses a
    # "Temperature:" line in the health section. Try both.
    TEMP="$(printf '%s' "$ATTRS" | awk '$2 == "Temperature_Celsius" {print $10; exit}')"
    if [ -z "$TEMP" ]; then
      TEMP="$(printf '%s' "$ATTRS" | awk -F: '/^Temperature:/ {gsub(/[^0-9]/,"",$2); print $2; exit}')"
    fi
    if [ -n "$TEMP" ] && [ "$TEMP" -gt 0 ] 2>/dev/null; then
      echo "smartctl_device_temperature{device=\"${name}\"} ${TEMP}"
    fi

    # The two attributes that actually predict failure, per the same reasoning
    # as stack-healthcheck.sh: any non-zero value is worth watching, and the
    # trend matters more than the absolute number.
    for pair in "Reallocated_Sector_Ct:reallocated_sectors" \
                "Current_Pending_Sector:pending_sectors" \
                "Power_On_Hours:power_on_hours"; do
      attr="${pair%%:*}"
      metric="${pair##*:}"
      RAW="$(printf '%s' "$ATTRS" | awk -v a="$attr" '$2 == a {print $10; exit}')"
      if [ -n "$RAW" ] && [ "$RAW" -ge 0 ] 2>/dev/null; then
        echo "smartctl_device_${metric}{device=\"${name}\"} ${RAW}"
      fi
    done
  done
} > "$TMP" 2>/dev/null

# Atomic swap so node-exporter never sees a partial file.
mv -f "$TMP" "$OUT"
chmod 0644 "$OUT"
