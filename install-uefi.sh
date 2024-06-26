#!/bin/bash

ln -sf /usr/share/zoneinfo/America/Buenos_Aires /etc/localtime
hwclock --systohc
#sed -i '177s/.//' /etc/locale.gen
sed -e 's/^#en_US.UTF-8/en_US.UTF-8/' -i /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=la-latin1" > /etc/vconsole.conf
echo "arch" >> /etc/hostname
echo "127.0.0.1 localhost" > /etc/hosts
echo "::1       localhost" > /etc/hosts
echo "127.0.1.1 arch.localdomain arch" > /etc/hosts
echo root:password | chpasswd

# Update archlinux keyring
pacman -Sy --noconfirm archlinux-keyring

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

useradd -m -g wheel -s /bin/bash zerohack
echo zerohack:wasd | chpasswd
#usermod -aG libvirt ermanno

echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/00-larbs-wheel-can-sudo

echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

## this is only required if nvidia drivers are previously installed as base packaged ##
#sed -e 's/MODULES=()/MODULES=(nvidia)/' -i /etc/mkinitcpio.conf
#mkinitcpio -p linux

printf "\e[1;32mDone! Type exit, umount -a and reboot.\e[0m"
