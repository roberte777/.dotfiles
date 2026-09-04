# Theater Server Configuration

NixOS configuration for the theater media server.

**Static IP:** 192.168.1.64

## Quick Commands

### Adding a New Hard Drive

```bash
# Automated setup
./scripts/setup-disk.sh /dev/sdX bayN

# Example: Adding second drive
./scripts/setup-disk.sh /dev/sdb bay2
```

See [docs/ADD_NEW_DISK.md](docs/ADD_NEW_DISK.md) for detailed manual instructions.

### Managing Docker Stack

```bash
# Start all services
docker compose up -d

# Stop all services
docker compose down

# View logs
docker compose logs -f [service_name]

# Restart specific service
docker compose restart [service_name]
```

### Storage Management

```bash
# Check mergerfs pool status
df -h /mnt/storage

# Check individual bay drives
df -h /mnt/bay*

# View drive usage
ncdu /mnt/storage

# Balance data across drives (if mergerfs.balance is available)
sudo mergerfs.balance /mnt/storage
```

### NixOS Management

```bash
# Rebuild configuration
sudo nixos-rebuild switch --flake .#theater

# Test configuration (doesn't activate)
sudo nixos-rebuild test --flake .#theater

# Rollback to previous generation
sudo nixos-rebuild switch --rollback
```

## Directory Structure

```
/mnt/bay1, bay2, bay3...  # Individual drive mounts
/mnt/storage              # MergerFS pool (combines all bays)
  ├── media/
  │   ├── movies/
  │   ├── tv/
  │   ├── audiobooks/
  │   └── books/
  ├── torrents/
  │   ├── movies/
  │   ├── tv/
  │   ├── audiobooks/
  │   ├── books/
  │   ├── completed/
  │   └── incomplete/
  └── usenet/
      ├── complete/
      └── incomplete/

/docker/appdata           # Docker container configs
```

## Services

All services are managed via docker-compose:

- **Gluetun**: VPN container for download clients
- **qBittorrent**: Torrent client (port 8081)
- **Prowlarr**: Indexer manager (port 9696)
- **SABnzbd**: Usenet client (port 8080)
- **Radarr**: Movie management (port 7878)
- **Sonarr**: TV show management (port 8989)
- **Bazarr**: Subtitle management (port 6767)
- **Jellyfin**: Media server (port 8096)
- **Plex**: Media server (port 32400)
- **Seerr**: Request management (port 5055/5056)
- **Profilarr**: Profile management (port 6868)
- **Homarr**: Dashboard (port 7575)
- **Watchtower**: Automatic container updates
- **ntfy**: Push notifications to phone (port 8085)
- **Uptime Kuma**: Service monitoring and alerting (port 3003)
- **Grafana**: Log search and dashboards (port 3004)
- **Loki**: Log storage, 30-day retention (localhost:3100)
- **Alloy**: Journal collector, ships to Loki (localhost:12345)

## Monitoring & Alerts

Two layers, because most of the interesting failures here leave every container
reporting "healthy".

### Layer 1 — Uptime Kuma (port 3003)

HTTP probes against each service. Configured through its web UI. Set the ntfy
notification to `http://ntfy:8085` with the topic from `.env`.

Because every VPN-namespace service shares gluetun's network, a gluetun outage
trips all of them at once. Set those monitors as **children of a gluetun
monitor** (Uptime Kuma → monitor → "Parent Monitor") to get one alert instead of
six.

### Layer 2 — `scripts/stack-healthcheck.sh`

Runs every 15 minutes via the `stack-healthcheck` systemd timer. Catches the
failures that HTTP probes cannot see:

| Check | Failure it catches |
|---|---|
| VPN exit IP ≠ house WAN IP | Tunnel dropped, traffic leaking from home IP |
| Forwarded port exists | gluetun picked a server without port forwarding |
| Port matches qBittorrent | `VPN_PORT_FORWARDING_UP_COMMAND` silently failed |
| MouseHole `lastMamContactResult` | MAM session rejected (returns HTTP **200** while broken) |
| qbittorrent-mam version ≤ 5.2.x | Client drifted outside MAM's allowed range |
| All `/mnt/bay*` mounted | A bay unmounted; mergerfs serves an incomplete pool silently |
| Pool under 90% full | Storage filling up |
| SMART reallocated/pending sectors | Drive degrading before it fails outright |

Run it by hand any time:

```bash
./scripts/stack-healthcheck.sh          # exits 1 if any check fails
systemctl start stack-healthcheck       # or via systemd
systemctl list-timers stack-healthcheck # confirm next run
journalctl -u stack-healthcheck -n 50   # see recent results
```

**When adding a drive**, bump `EXPECTED_BAYS` in the script. It is hardcoded on
purpose: deriving it from what is currently mounted would let a missing bay
define itself out of existence.

### Layer 3 — Grafana + Loki (port 3004)

Searchable logs across every container. Layers 1 and 2 catch failures you can
name in advance; this catches the ones you cannot. The shelfarr incident is the
worked example: it ran its health check 48x too often for weeks while every
container reported healthy and every probe stayed green. The only signal was log
volume, and nothing was watching it.

Docker uses the journald log driver here, so all containers already log to one
place with `CONTAINER_NAME` attached. Alloy reads the journal directly — no
logging config on any other service, no sidecars.

Log in at `http://192.168.1.64:3004` with the credentials in `.env`
(`GRAFANA_ADMIN_*`, read only at first boot — change it in the UI afterwards).

Two provisioned dashboards, both in the **Media Stack** folder:

- **Logs & Anomalies** — log volume, error rates, rate-vs-baseline (Loki)
- **Host & Containers — Resources** — CPU, memory, disk, temperature, and
  per-container CPU/memory (Prometheus)

Use **Explore** for ad-hoc work.

#### Metrics: Prometheus + node-exporter + cadvisor

Loki answers "what did a service say"; these answer "what is the machine
doing". Neither sees the other's failures, and the shelfarr incident is the
case for both: log volume held the signal, but per-container CPU would have
shown it too.

`cadvisor` is the piece that matters most — it turns "memory is climbing" into
"shelfarr's memory is climbing", which is exactly the attribution that was
missing when that took weeks to find.

Prometheus keeps 90 days at a 15s scrape. Only Grafana is exposed; Prometheus
(9090) and cadvisor (8086) bind 127.0.0.1 like Loki.

**Two NixOS-specific traps**, both of which fail *silently* — the scrape looks
healthy while producing nothing usable:

- **cadvisor needs `--containerd=/var/run/docker/containerd/containerd.sock`.**
  NixOS does not use the `/run/containerd` default it compiles in. Without it,
  cadvisor's docker factory fails to register, it falls back to the Raw factory,
  and every series comes back as `id="/"` with no `name` label.
- **node-exporter needs an explicit firewall rule.** It runs with
  `network_mode: host` so it can see real interfaces, which puts it on the
  host's 9100 rather than the compose network. NixOS defaults to DROP, so
  Prometheus cannot reach it. The rule in `default.nix` is scoped to the docker
  bridge interfaces rather than added to `allowedTCPPorts` — node-exporter
  exposes host memory, filesystem layout and process stats with no auth, and
  that list would open it to the whole LAN.

**Config files live in `observability/` in this repo.** `make_dirs.sh` creates
the directories; these are what goes in them. Loki, Alloy and Prometheus do not
start at all without their config, and Grafana comes up with no datasources or
alert rules — a state that looks like a working install until you notice
everything is empty. After `make_dirs.sh`:

```bash
cp -r observability/* /docker/appdata/
cp /docker/appdata/grafana/provisioning/alerting/contact-points.yaml.example \
   /docker/appdata/grafana/provisioning/alerting/contact-points.yaml
# then replace REPLACE_WITH_NTFY_TOPIC in that file with NTFY_TOPIC from .env
```

`scripts/sync-observability-configs.sh` copies the live files back into the
repo after you edit them; `--check` exits non-zero if the repo is stale.
The ntfy contact point is written as a `.example` with the topic stripped,
since that topic is the only secret on an unauthenticated ntfy instance.

**Dashboard JSON is deliberately not in the repo** — panel layout churns
whenever it is edited in the UI, and a stale copy is worse than none. Rebuild
dashboards in the UI if the disk is ever lost; the queries that matter are in
this file.

To check the pipeline is actually working:

```bash
curl -s 'http://127.0.0.1:9090/api/v1/targets?state=any' | jq -r \
  '.data.activeTargets[] | "\(.labels.job): \(.health) \(.lastError // "")"'
```

#### The `level` label is parsed, not inherited

Worth knowing before trusting any `level=` query: Docker's journald driver
stamps **every stderr line** as `PRIORITY=3` ("err"), regardless of what the app
actually logged. Anything that writes to stderr therefore arrives 100%
`level="error"`. Before this was fixed, omnibus showed 35,190 "errors" in 24h
and ntfy 1,441 — all of them routine INFO and DEBUG lines.

So Alloy discards the journald level and re-derives it from the message text,
with a regex per log format (*arr `[Info]`, Python `- INFO -`, Rust tracing,
Go `2026/08/26 ... INFO`, seerr `[debug]`). **Any line no regex matched defaults
to `info`** — including banners, separators, and the 2nd..Nth line of a
multi-line record, which carry no level of their own.

That default is keyed on "no level parsed", not on container name. Scoping it
per-container instead leaves unparsed lines holding journald's bogus `error`:
profilarr's import summary (`Added: 0, Updated: 250, Failed: 5`) did exactly
that and pushed the error-rate alert into `pending` on 62 non-errors.

The fallback deliberately does **not** grep for words like "error" or "failed".
A summary line reading `Failed: 5` is not an error event, and counting it as one
is what makes a rate-based alert cry wolf.

Two traps if you edit `config.alloy`:

- `stage.replace` rewrites the **stored** line but later stages still parse the
  original text, so ANSI-stripping does not help a downstream regex. Patterns
  must tolerate inline escape codes themselves.
- Alloy uses RE2. `\x1b` is not valid; write `\033`.

To debug the pipeline, `livedebugging` is enabled — this streams the `[IN]` and
`[OUT]` label set for every line and is the only practical way to see what a
stage did:

```bash
curl -s -N "http://127.0.0.1:12345/api/v0/web/debug/loki.process.dedupe_labels?sampleProb=1"
```

Useful LogQL to start from:

```logql
{container="shelfarr"}                      # one service
{container=~"radarr|sonarr"} |= "error"     # several, filtered
{level="error"}                             # errors across the whole stack
{unit="stack-healthcheck.service"}          # host units, not just containers

# Rate of a specific line -- how the shelfarr fix was verified
sum(count_over_time({container="shelfarr"} |= "Performing HealthCheckJob" [5m]))

# Noisiest containers over the last hour
topk(10, sum by (container) (count_over_time({job="systemd-journal"} [1h])))
```

That last query is the one to run when the box feels slow or the disk is
filling. It is how the shelfarr and homarr problems were found in the first
place.

#### Alerts

Three rules, provisioned in `${APPDATA_DIR}/grafana/provisioning/alerting/`,
firing to the existing ntfy topic. They are deliberately **generic** — none of
them knows what shelfarr is, and rule 1 would have caught that incident on day
one without anyone predicting it:

| Rule | Fires when | `for` |
|---|---|---|
| Log volume spiked vs baseline | container's 5m rate is >4x its own 6h average | 15m |
| Sustained error rate | >25 errors in 5m from one container | 10m |
| Chatty container gone silent | a normally-busy container logs nothing | 20m |

The `for` durations matter: a restart or a library scan spikes any container
briefly, and paging on that trains you to ignore the alerts. Rule 1 also floors
the denominator (`> 0.01`) so near-idle containers — where one log line reads as
a 70x spike — cannot trip it.

The third rule is the inverse failure: a wedged process that still holds its
port open looks healthy to Uptime Kuma but stops logging.

Five more in `rules-resources.yaml`, over Prometheus. These are about **trend**,
which is what the threshold checks cannot express:

| Rule | Fires when | `for` |
|---|---|---|
| Filesystem predicted to fill | `predict_linear` says <14 days of runway | 1h |
| Host memory available low | MemAvailable under 10% | 15m |
| Drive temperature high | a drive over 50C (SMART, not hwmon) | 20m |
| Container memory climbing | working set up >50% over 6h, >200MB | 30m |
| Scrape target down | Prometheus cannot reach an exporter | 10m |

The disk rule is the one that earns its keep: `stack-healthcheck.sh` fires at
90% full, which is true but late. This fires weeks earlier, while pruning or
buying a drive is still a calm decision.

The last rule exists because without it the entire metrics pipeline can die
silently and every rule above just reads OK forever. It has already earned its
keep once, firing when node-exporter was unreachable before the firewall rule
was applied.

**The temperature rule reads SMART, not hwmon.** hwmon on this box exposes the
CPU package, NVMe, wifi and a thermal zone — but *not* the SATA spinner, which
is the drive the rule exists for. An earlier version used
`max(node_hwmon_temp_celsius)`, which watched every component except that drive
and would have false-fired on a CPU package temp during a transcode (routinely
70C+) while reporting it as a drive problem.

The `smart-textfile` systemd timer runs `scripts/smart-textfile.sh` as root
every 5 minutes and writes temperature, reallocated/pending sectors and
power-on hours to `/var/lib/node-exporter/textfile/smart.prom`, which
node-exporter reads via its textfile collector. Check it with:

```bash
systemctl status smart-textfile.timer
cat /var/lib/node-exporter/textfile/smart.prom
```

Tuning thresholds: edit `rules.yaml` and `docker compose restart grafana`. The
files on disk win, so changes made in the UI are overwritten on restart.

**The contact point holds the ntfy topic in plaintext** — Grafana provisioning
cannot read env vars in contact point settings. Keep
`provisioning/alerting/contact-points.yaml` out of git, and if `NTFY_TOPIC` is
rotated, update it there too.

**Retention**: Loki keeps 30 days; journald is capped at 2G (a few weeks at
current volume). Loki's compacted chunks are far smaller than the raw journal,
so the longer window still costs well under a gig.

**Ports**: only Grafana (3004) is exposed. Loki and Alloy bind to 127.0.0.1 and
are reached over the compose network — Loki holds everything the stack logs,
including request paths and error detail, and has no auth of its own.

### Phone setup

Install the ntfy app (iOS/Android), then **Add subscription**:

- Topic: the `NTFY_TOPIC` value from `.env`
- Server: uncheck "Use ntfy.sh", enter the `NTFY_BASE_URL` from `.env`
  (`http://theater.tail4d5f23.ts.net:8085` — the MagicDNS name, not the 100.x
  IP, which is reassigned on logout/re-login or a rebuild)

Delivery works away from home **as long as Tailscale is connected on the
phone**, which is its normal background state. `NTFY_UPSTREAM_BASE_URL` relays a
wake-up via ntfy.sh's Apple push certificate, but the app then fetches the
message body from this server — so with Tailscale fully disabled the
notification still arrives, without its text.

The topic name is the only secret — anyone who can reach the server and guess it
can publish. Regenerate it if it leaks:

```bash
echo "theater-alerts-$(head -c 9 /dev/urandom | base32 | tr '[:upper:]' '[:lower:]' | tr -d '=')"
```

## MergerFS Configuration

The storage pool uses mergerfs with these settings:

- **category.create=mfs**: New files go to drive with most free space
- **moveonenospc=true**: Automatically move files if a drive fills up
- **Pattern**: `/mnt/bay*` (automatically includes all bayN mounts)

## Useful Scripts

- `./scripts/setup-disk.sh` - Automated disk setup and addition to pool

## Known Issues

- [docs/SHELFARR_HEALTHCHECK_CHAINS.md](docs/SHELFARR_HEALTHCHECK_CHAINS.md) —
  shelfarr accumulates a self-perpetuating `HealthCheckJob` chain on every
  restart, silently multiplying its health-check rate until it floods the
  journal with Hardcover rate-limit errors. Cleared 2026-08-24; **regrows by one
  per restart**, so re-check after watchtower updates or reboots.

## Environment Variables

Configuration is stored in `.env`:

- `DATA_DIR`: Main data directory (currently `/mnt/storage`)
- `APPDATA_DIR`: Docker app configs (currently `/docker/appdata`)
- `PUID/PGID`: User/group IDs for container permissions
- `TZ`: Timezone
- VPN credentials and other service-specific settings

## Troubleshooting

### Mergerfs not showing all drives
```bash
# Check which drives are mounted
mount | grep /mnt/bay

# Remount mergerfs
sudo umount /mnt/storage
sudo mount /mnt/storage
```

### Docker services can't access media
```bash
# Check permissions
ls -la /mnt/storage

# Fix ownership
sudo chown -R theater:users /mnt/storage
```

### Check hardware transcoding
```bash
# Intel GPU status
intel_gpu_top

# VAAPI devices
ls -la /dev/dri
```
