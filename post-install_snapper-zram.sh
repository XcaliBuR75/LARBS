#!/bin/sh

sudo umount /.snapshots
sudo rm -r /.snapshots
sudo snapper -c root create-config /
sudo btrfs subvolume delete /.snapshots
sudo mkdir /.snapshots
sudo mount -a
sudo chmod 750 /.snapshots
sudo sed -e 's/ALLOW_USERS=""/ALLOW_USERS="zerohack"/' -i /etc/snapper/configs/root
sudo sed -e 's/TIMELINE_LIMIT_YEARLY="10"/TIMELINE_LIMIT_YEARLY="0"/' -i /etc/snapper/configs/root
sudo sed -e 's/TIMELINE_LIMIT_MONTHLY="10"/TIMELINE_LIMIT_MONTHLY="0"/' -i /etc/snapper/configs/root
sudo sed -e 's/TIMELINE_LIMIT_DAILY="10"/TIMELINE_LIMIT_DAILY="7"/' -i /etc/snapper/configs/root
sudo sed -e 's/TIMELINE_LIMIT_HOURLY="10"/TIMELINE_LIMIT_HOURLY="5"/' -i /etc/snapper/configs/root
sudo systemctl enable --now snapper-timeline.timer
sudo systemctl enable --now snapper-cleanup.timer

## Installing snap-pac-grub

sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
paru -S snap-pac-grub

## For backing up the boot partition when system update is being run
sudo mkdir -p /etc/pacman.d/hooks
printf "[Trigger]\nOperation = Upgrade\nOperation = Install\nOperation = Remove\nType = Path\nTarget = boot/*\n\n[Action]\nDepends = rsync\nDescription = Backing up /boot...\nWhen = PreTransaction\nExec = /usr/bin/rsync -a --delete /boot /.bootbackup" > /tmp/50-bootbackup.hook
sudo cp /tmp/50-bootbackup.hook /etc/pacman.d/hooks/

## Changing permition and ownership of the .snapshots folder
sudo chmod a+rx /.snapshots
sudo chown :zerohack /.snapshots

## zram configuration
paru -S zramd
sudo sed -e 's/\# MAX_SIZE=8192/MAX_SIZE=2048/' -i /etc/default/zramd
sudo systemctl enable --now zramd.service

## Using overlayfs to allow booted snapshots like a live-cd in non-persistent mode
sudo sed -e 's/fsck)/fsck grub-btrfs-overlayfs)/' -i /etc/mkinitcpio.conf
sudo mkinitcpio -P
