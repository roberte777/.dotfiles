# This is a placeholder hardware-configuration.nix for the theater host.
# Regenerate this file on the actual machine with:
#   nixos-generate-config --show-hardware-config > hardware-configuration.nix
{
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Boot configuration - adjust based on actual hardware
  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  # Filesystems - MUST be configured for actual hardware
  # Run `nixos-generate-config` on the theater machine to get correct UUIDs
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  swapDevices = [];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
