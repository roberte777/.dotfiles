# Adding a New Disk to MergerFS Pool

This guide walks you through adding a new hard drive to your mergerfs storage pool.

## Prerequisites

- Physical drive installed in a bay
- Root/sudo access
- Existing mergerfs pool at `/mnt/storage`

## Quick Setup

Use the automated script:

```bash
cd /home/theater/.dotfiles/nix/hosts/theater
./scripts/setup-disk.sh /dev/sdX bayN
```

Replace:
- `/dev/sdX` with your disk device (e.g., `/dev/sdb`)
- `bayN` with the bay number (e.g., `bay2`, `bay3`, etc.)

The script will:
1. Partition and format the disk
2. Create mount point
3. Add to NixOS configuration
4. Create directory structure matching existing setup
5. Rebuild NixOS
6. Offer to balance data across drives

## Manual Setup

If you prefer to do it manually:

### 1. Identify the New Disk

```bash
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE,MODEL
```

Find your new disk (e.g., `/dev/sdb`).

### 2. Partition and Format

```bash
# Create GPT partition table and partition
echo -e "g\nn\n\n\n\nw" | sudo fdisk /dev/sdX

# Format with ext4
sudo mkfs.ext4 /dev/sdX1

# Get the UUID
sudo blkid /dev/sdX1
```

### 3. Create Mount Point

```bash
sudo mkdir -p /mnt/bayN
```

### 4. Update NixOS Configuration

Edit `/home/theater/.dotfiles/nix/hosts/theater/default.nix`:

```nix
# Add after existing bay mounts
fileSystems."/mnt/bayN" = {
  device = "/dev/disk/by-uuid/YOUR-UUID-HERE";
  fsType = "ext4";
};
```

### 5. Rebuild NixOS

```bash
cd /home/theater/.dotfiles/nix/hosts/theater
sudo nixos-rebuild switch --flake .#theater
```

The mergerfs pool will automatically include the new drive!

### 6. Create Directory Structure

```bash
sudo mkdir -p /mnt/bayN/{media/{movies,tv,audiobooks,books},torrents/{movies,tv,audiobooks,books,completed,incomplete},usenet/{complete,incomplete}}
sudo chown -R theater:users /mnt/bayN
```

### 7. (Optional) Balance Data

To redistribute files across all drives:

```bash
mergerfs.balance /mnt/storage
```

Or manually move specific folders to the new drive:

```bash
# Example: Move some movies to new drive
rsync -avhP --remove-source-files /mnt/bay1/media/movies/SomeMovie/ /mnt/bayN/media/movies/SomeMovie/
```

## Verification

Check that mergerfs sees the new drive:

```bash
# Should show increased total size
df -h /mnt/storage

# Verify all bay drives are included
mount | grep mergerfs
```

## Notes

- MergerFS automatically includes all `/mnt/bay*` drives
- New files will be written to the drive with most free space (`category.create=mfs`)
- Existing files stay where they are unless you manually balance
- If a drive fills up, mergerfs will automatically move new files to another drive (`moveonenospc=true`)
