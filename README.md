## Utilities to investigate
- Swappy: nice tool for post screenshot
- grim: screenshots

## Fixing Grub

### Grub not showing up

After the minimal installation, you may face the issue of the grub not showing up. Thus, we click on yes for post installation configuration and then run the following commands sequentially:

```bash
pacman -Sy grub efibootmgr dosfstools mtools
```

```bash
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
```

```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

Then exit and shutdown the system and then boot it up again.

### Windows not showing up in Grub

If you have Windows installed and it is not showing up in the grub, then run the following commands sequentially:

- Install os-prober, if not already installed:

  ```bash
  pacman -S os-prober
  ```

- Edit the file `etc/default/grub` and add the following line:

  ```bash
  GRUB_DISABLE_OS_PROBER=false
  ```

- Update the grub configuration:

  ```bash
  grub-mkconfig -o /boot/grub/grub.cfg
  ```

### How to revive arch linux after any windows updates?

1. Boot into the arch linux live usb.

2. Connect to the internet and update all the packages as follows:

   ```bash
   pacman -Sy
   ```

3. Mount the root partition of the arch linux to /mnt and the boot partition to /mnt/boot like:

   ```bash
   mount /dev/nvme0n1p5 /mnt
   ```

   ```bash
   mount /dev/nvme0n1p6 /mnt/boot
   ```

   ```bash
   arch-chroot /mnt
   ```

4. Run the grub-install and grub-mkconfig commands as mentioned above.

