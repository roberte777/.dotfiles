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
