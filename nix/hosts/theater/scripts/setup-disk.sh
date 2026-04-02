#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
usage() {
    echo "Usage: $0 <disk_device> <bay_name>"
    echo ""
    echo "Arguments:"
    echo "  disk_device   The disk device to setup (e.g., /dev/sdb)"
    echo "  bay_name      The bay name for mounting (e.g., bay2, bay3)"
    echo ""
    echo "Example:"
    echo "  $0 /dev/sdb bay2"
    echo ""
    echo "This script will:"
    echo "  1. Partition and format the disk as ext4"
    echo "  2. Create mount point at /mnt/<bay_name>"
    echo "  3. Add filesystem to NixOS configuration"
    echo "  4. Rebuild NixOS configuration"
    echo "  5. Create directory structure matching existing setup"
    echo "  6. Optionally balance data across drives"
    exit 1
}

# Check arguments
if [ $# -ne 2 ]; then
    print_error "Invalid number of arguments"
    usage
fi

DISK_DEVICE="$1"
BAY_NAME="$2"
MOUNT_POINT="/mnt/${BAY_NAME}"
PARTITION="${DISK_DEVICE}1"
NIX_CONFIG="/home/theater/.dotfiles/nix/hosts/theater/default.nix"
REFERENCE_MOUNT="/mnt/storage"

# Validate disk device exists
if [ ! -b "$DISK_DEVICE" ]; then
    print_error "Disk device $DISK_DEVICE does not exist"
    exit 1
fi

# Validate bay name format
if [[ ! "$BAY_NAME" =~ ^bay[0-9]+$ ]]; then
    print_error "Bay name must be in format 'bayN' where N is a number (e.g., bay2, bay3)"
    exit 1
fi

# Check if mount point already exists
if mountpoint -q "$MOUNT_POINT" 2>/dev/null; then
    print_error "$MOUNT_POINT is already mounted"
    exit 1
fi

# Confirm with user
echo ""
print_warning "WARNING: This will DESTROY ALL DATA on $DISK_DEVICE"
echo ""
echo "Disk to setup: $DISK_DEVICE"
echo "Bay name: $BAY_NAME"
echo "Mount point: $MOUNT_POINT"
echo ""
lsblk "$DISK_DEVICE" 2>/dev/null || true
echo ""
read -p "Are you sure you want to continue? (yes/no): " -r
echo ""
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    print_info "Aborted by user"
    exit 0
fi

# Step 1: Partition the disk
print_info "Creating GPT partition table on $DISK_DEVICE..."
echo -e "g\nn\n\n\n\nw" | sudo fdisk "$DISK_DEVICE" > /dev/null 2>&1
print_success "Partition table created"

# Wait for partition to be recognized
sleep 2

# Step 2: Format the partition
print_info "Formatting $PARTITION as ext4..."
sudo mkfs.ext4 -F "$PARTITION" > /dev/null 2>&1
print_success "Partition formatted"

# Step 3: Get UUID
print_info "Getting partition UUID..."
UUID=$(sudo blkid -s UUID -o value "$PARTITION")
if [ -z "$UUID" ]; then
    print_error "Failed to get UUID for $PARTITION"
    exit 1
fi
print_success "UUID: $UUID"

# Step 4: Create mount point
print_info "Creating mount point at $MOUNT_POINT..."
sudo mkdir -p "$MOUNT_POINT"
print_success "Mount point created"

# Step 5: Temporarily mount to create directory structure
print_info "Temporarily mounting disk to create directory structure..."
sudo mount "$PARTITION" "$MOUNT_POINT"
print_success "Disk mounted"

# Step 6: Create directory structure
print_info "Creating directory structure..."
sudo mkdir -p "$MOUNT_POINT"/{media/{movies,tv,audiobooks,books},torrents/{movies,tv,audiobooks,books,completed,incomplete},usenet/{complete,incomplete}}
sudo chown -R theater:users "$MOUNT_POINT"
print_success "Directory structure created"

# Step 7: Unmount
print_info "Unmounting disk..."
sudo umount "$MOUNT_POINT"
print_success "Disk unmounted"

# Step 8: Add to NixOS configuration
print_info "Adding filesystem to NixOS configuration..."

# Check if this bay is already configured
if grep -q "fileSystems.\"/mnt/${BAY_NAME}\"" "$NIX_CONFIG"; then
    print_warning "Configuration for $MOUNT_POINT already exists in NixOS config"
    print_info "Updating UUID..."
    # This is a simple approach - in production you might want more sophisticated editing
    print_warning "Please manually update the UUID in $NIX_CONFIG to: $UUID"
else
    # Find the last bay mount and add after it
    # Insert before the mergerfs mount
    NEW_MOUNT="
  fileSystems.\"/mnt/${BAY_NAME}\" = {
    device = \"/dev/disk/by-uuid/${UUID}\";
    fsType = \"ext4\";
  };
"

    # Use awk to insert after the last bay mount but before mergerfs
    awk -v new_mount="$NEW_MOUNT" '
        /fileSystems."\/mnt\/bay[0-9]+"/ {
            last_bay_end = NR
        }
        {
            lines[NR] = $0
        }
        END {
            for (i = 1; i <= NR; i++) {
                print lines[i]
                if (i == last_bay_end + 2) {  # After the closing brace and semicolon
                    print new_mount
                }
            }
        }
    ' "$NIX_CONFIG" > "${NIX_CONFIG}.tmp"

    sudo mv "${NIX_CONFIG}.tmp" "$NIX_CONFIG"
    print_success "NixOS configuration updated"
fi

# Step 9: Rebuild NixOS
print_info "Rebuilding NixOS configuration..."
cd "$(dirname "$NIX_CONFIG")"
if sudo nixos-rebuild switch --flake .#theater; then
    print_success "NixOS rebuilt successfully"
else
    print_error "NixOS rebuild failed"
    exit 1
fi

# Step 10: Verify mount
print_info "Verifying mount..."
if mountpoint -q "$MOUNT_POINT"; then
    print_success "$MOUNT_POINT is mounted"
else
    print_error "$MOUNT_POINT is not mounted"
    exit 1
fi

# Step 11: Verify mergerfs pool
print_info "Checking mergerfs pool..."
df -h "$REFERENCE_MOUNT"
echo ""
mount | grep mergerfs
echo ""
print_success "Disk successfully added to mergerfs pool!"

# Step 12: Ask about balancing
echo ""
print_info "The disk has been added successfully!"
print_info "New files will automatically use the drive with most free space."
echo ""
read -p "Would you like to balance existing data across all drives now? (yes/no): " -r
echo ""

if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    print_info "Starting data balance across all drives..."
    print_warning "This may take a long time depending on the amount of data."
    print_info "Files will be moved to balance free space across all drives."
    echo ""

    if command -v mergerfs.balance &> /dev/null; then
        sudo mergerfs.balance "$REFERENCE_MOUNT"
        print_success "Data balancing complete!"
    else
        print_warning "mergerfs.balance command not found."
        print_info "You can manually balance by moving folders between /mnt/bay* directories"
        print_info "Example: rsync -avhP --remove-source-files /mnt/bay1/media/movies/SomeMovie/ $MOUNT_POINT/media/movies/SomeMovie/"
    fi
else
    print_info "Skipping data balancing."
    print_info "You can manually balance later by moving folders between /mnt/bay* directories"
fi

echo ""
print_success "Setup complete!"
print_info "Summary:"
print_info "  Device: $DISK_DEVICE ($PARTITION)"
print_info "  UUID: $UUID"
print_info "  Mount: $MOUNT_POINT"
print_info "  Pool: $REFERENCE_MOUNT"
echo ""
print_info "Check pool status with: df -h $REFERENCE_MOUNT"
