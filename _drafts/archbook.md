---
layout: post
title: Archbook
---

# Device description

- MacBook Pro(Retina, 13-inch, Early 2015)
- Processor: 	2,7 Ghz Dual-Core Intel Core i5
- Memory: 	8GB 1867 Mhz DDR3
- Graphic: 	Intel Iris Graphics 6100 1536 MB
- SSD: 		128GB
- Keyboard: 	en_US
 
# Installation description

Arch Linux with OS X 
System encryption
Boot loader: EFI

# Pre-installation

The checklist to be done before booting the live environment

## Firmware update

Ensure that the latest firmware update for the MacBook are installed.
- Open App Store and check for updates
- Install the update
- Reboot and check again for update

## Disk partition

Create a Disk partition for Arch linux
- Open Disk Utils
- Add a new partition

## Create an installation Medium

Create a USB flash installation medium
- Download iso
- Check the iso
- Plug the USB
- Identify the USB device: `diskutil list`
- Unmount the USB device: `diskutil unmountDisk /dev/diskX
- Copy the iso: `dd if=path/to/archlinux-version-x86_64.iso of=/dev/rdiskX bs=1m`

# Installation

## Live environment setup

In live environment setup

- Reboot and press `alt`
- Boot the live environment
- Setup the console keyboard layout (default is US)
> _ls /usr/share/kbd/keymaps/**/*.map.gz_
> _loadkeys de-latin1
- Verify the boot mode
> ls /sys/firmware/efi/efivars -> it should shows without error
- connect to the internet
> ip link
> iwctl
> station <device> connect <SSID>
- update system clock
> timedatectl set-ntp true

## Encryption

### Drive preparation

Erase the disk
- Check the partition to be wiped
> lsblk
- Create a temporary encrypted container
> cryptsetup open --type plain -d /dev/urandom /dev/sda3 to_be_wiped
- Check
> lsblk
- Wipe the container
> dd if=/dev/zero of=/dev/mapper/to_be_wiped bs=1m status=progress
_ Close the container
> cryptsetup close to_be_wiped

### Drive encryption

Encrypt the device
- Check the partition
> cryptsetup luksFormat /dev/sda3
- Proceed with password

### Drive partition

Partion the disk
- cryptsetup open /dev/sda3 lvm
- pvcreate /dev/mapper/lvm
- vgcreate arch /dev/mapper/lvm
- lvcreate -L 8G arch -n swap
- lvcreate -L 32G arch -n root
- lvcreate -l 100%FREE arch -n home

Format the disks
- mkfs.ext4 /dev/arch/root
- mkfs.ext4 /dev/arch/home
- mkswap /dev/arch/swap

# Mount the file system

- mount /dev/mapper/arch-root /mnt
- mkdir /mnt/home
- mount /dev/mapper/arch-home /home
- swapon /dev/mapper/arch-swap
- mkdir /mnt/boot
- mount /dev/sda1 /mnt/boot
- check lsblk

# Base installation

pacstrap -i /mnt base base-devel linux linux-firmware intel-ucode
pacstrap -i /mnt gvim lvm2 man-db man-pages iwd

# Configure the system

- genfstab -L -p /mnt >> /mnt/etc/fstab (?)
- discard option for SSD
- arch-chroot /mnt
- ln -st /usr/share/zoneinfo/<Region>/<City> /etc/localtime
- hwclock -systohc
- uncomment en_US.UTF-8 UTF-8 in /etc/locale.gen
- locale-gen
- echo LANG=en_US.UTF-8 > /etc/locale.conf
- passwd (root password)
- useradd --create-home --groups wheel --shell /bin/bash <USER>
- passwd <USER> (user password)
- visudo (%wheel ALL=(ALL) ALL
- echo archbook > /etc/hostname
- /etc/mkinitcpio.conf
> HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt lvm2 filesystems fsck)
- /boot/loader/loader.conf
> #timeout 3
> #console-mode keep
> default arch-*
- /boot/loader/entries/arch.conf
> title		Arch Linux
> linux		/vmlinuz-linux
> initrd	/intel-ucode.img
> initrd	/initramfs-linux.img
> options	cryptdevice=/dev/sda3:arch::allow-discards root=/dev/mapper/arch-root rw
- bootctl --path=/boot install

# Configuration

# Network Setup
systemctl start/enable iwd
systemctl start/enable systemd-networkd
systemctl start/enable systemd-resolved

Name resolution
in /etc/iwd/main.conf 

[General]
EnableNetworkConfiguration=true

[Network]
NameResolvingService=systemd (default)
DHCP=yes

in /etc/systemd/network/25-wireless.network
[Match]
Name=wlan0 

[Network]
DHCP=yes

[DHCPv4]
RouteMetric=20

# post installation

Graphic
lscpi | grep VGA -> intel -> mesa
xf86-video-intel

Network
lscpi | grep Network -> Broadcom -> brcm80211

# xorg, i3, firefox

in /etc/systemd/network/25-wireless.network

sudo pacman -S xorg i3 firefox xorg-xinit xterm dmenu

#firefox dpi
About:config

pixel 1.5

# xinitrc

#!/bin/sh

XRESOURCES=$HOME/.Xresources

if [ -f "$XRESOURCES" ]; then
	xrdb -merge ~/.Xresources
fi

exec i3

# .Xresources

!-- Xft settings --!
Xft.dpi:		192
Xft.rgba:		rgb
Xft.autohint:		0
Xft.lxdfilter:		lcddefault
Xft.hintstyle:		hintfull
Xft.hinting:		1
Xft.antialias:		1

!-- Xterm settings --!
xterm*faceName:		Monospace
xterm*faceSize:		8
xterm*background:	black
xterm*foreground: 	lightgray

/etc/X11/xorg.conf.d/00-keyboard.conf

Section "InputClass"
        Identifier "system-keyboard"
        MatchIsKeyboard "on"
        Option "XkbOptions" "ctrl:nocaps"
EndSection


#SOUND
apulse
alsa-utils

select cards 1

apulse firefox

# POWERTOP
sudo pacman -S powertop

[Unit]
Description=Powertop tunings

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/powertop --auto-tune

[Install]
WantedBy=multi-user.target

powertop --calibrate

# I3lock
