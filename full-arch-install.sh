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

ln -sf /usr/share/zoneinfo/America/Buenos_Aires /etc/localtime
hwclock --systohc
sed -i '177s/.//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=la-latin1" > /etc/vconsole.conf
echo "arch" >> /etc/hostname
echo "127.0.0.1 localhost" > /etc/hosts
echo "::1       localhost" > /etc/hosts
echo "127.0.1.1 arch.localdomain arch" > /etc/hosts
echo root:password | chpasswd

# You can add xorg to the installation packages, I usually add it at the DE or WM install script
# You can remove the tlp package if you are installing on a desktop or vm

pacman -S --disable-download-timeout grub grub-btrfs efibootmgr networkmanager network-manager-applet xorg-server xorg-xwininfo xorg-xinit xorg-xprop xorg-xdpyinfo xorg-xbacklight snapper xcape xclip xdotool dialog wpa_supplicant mtools dosfstools reflector base-devel linux-headers avahi xdg-user-dirs xdg-utils gvfs gvfs-smb nfs-utils inetutils dnsutils bluez bluez-utils cups hplip alsa-utils pulseaudio pavucontrol openssh rsync reflector acpi acpi_call edk2-ovmf bridge-utils dnsmasq vde2 openbsd-netcat iptables-nft ipset firewalld sof-firmware nss-mdns acpid os-prober ntfs-3g sudo


# pacman -S --noconfirm xf86-video-amdgpu
# pacman -S --noconfirm nvidia nvidia-utils nvidia-settings

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable sshd
systemctl enable avahi-daemon
#systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable firewalld
systemctl enable acpid

useradd -m zerohack
echo zerohack:wasd | chpasswd
#usermod -aG libvirt ermanno

echo "zerohack ALL=(ALL) ALL" >> /etc/sudoers.d/zerohack

echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

## this is only required if nvidia drivers are previously installed as base packaged ##
#sed -e 's/MODULES=()/MODULES=(nvidia)/' -i /etc/mkinitcpio.conf
#mkinitcpio -p linux

#printf "\e[1;32mDone! Type exit, umount -a and reboot.\e[0m"

su - zerohack
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
printf "\e[1;32mDone! Type exit, umount -a and reboot.\e[0m"
