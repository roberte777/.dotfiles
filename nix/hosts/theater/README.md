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
