#!/usr/bin/bash

umount /mnt/archbootc/boot || echo "not mounted"
umount /mnt/archbootc || echo "not mounted"
cryptsetup open /dev/vdc2 my-luks
mount -o subvol=@ /dev/mapper/my-luks /mnt/archbootc
# mount -o subvol=@home /dev/mapper/my-luks /mnt/archbootc/home
# mount -o subvol=@log /dev/mapper/my-luks /mnt/archbootc/var/log
# mount -o subvol=@pkg /dev/mapper/my-luks /mnt/archbootc/var/cache/pacman/pkg
mount /dev/vdc1 /mnt/archbootc/boot
rm -rf /mnt/archbootc/ || echo "ok"
podman run --rm --privileged --pid=host -v /:/target -v /dev:/dev -v /var/lib/containers:/var/lib/containers -e RUST_LOG=debug ghcr.io/physicsisawesome/arch-bootc-sealed:latest bootc install to-filesystem --composefs-backend  --bootloader systemd --boot-mount-spec UUID=56C2-1AA3 /target/mnt/archbootc
umount /mnt/archbootc/boot
umount /mnt/archbootc
