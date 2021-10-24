#!/bin/sh

sudo pacman --noconfirm -S gtkmm
sudo pacman --noconfirm -S open-vm-tools
sudo pacman --noconfirm -S xf86-video-vmware xf86-input-vmmouse
sudo systemctl enable vmtoolsd.service

printf "\e[1;32mDone! Type exit, please reboot your system so the instalation take effect.\e[0m"
