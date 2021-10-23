#!/bin/sh

timedatectl set-ntp true
loadkeys la-latin1
mkfs.vfat /dev/sda1
mkfs.btrfs /dev/sda2
mount /dev/sda2 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@var_log
umount /mnt
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@ /dev/sda2 /mnt
mkdir -p /mnt/{boot,home,.snapshots}
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@home /dev/sda2 /mnt/home
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@snapshots /dev/sda2 /mnt/.snapshots
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@var_log /dev/sda2 /mnt/var/log
mount /dev/sda1 /mnt/boot
pacstrap /mnt base linux linux-firmware git dos2unix vim amd-ucode
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
