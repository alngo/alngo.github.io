---
layout: post
title: Archbook
---

> A little mouse told me to consider Arch as my main OS.<br/>
> I always listen to Mouse. :mouse:

### Table of content
- [Device description](#device_description)
- [Installation description](#installation_description)
- [Procedure](#procedure)
  - [Pre-installation](#pre_installation)
  - [Installation](#installation)
    - [Live environment configuration](#live_environment_configuration)

<a name="device_description"></a>
### Device description

```
- Device:       MacBook Pro(Retina, 13-inch, Early 2015)
- Processor:    2,7 Ghz Dual-Core Intel Core i5
- Memory:       8GB 1867 Mhz DDR3
- Graphic:      Intel Iris Graphics 6100 1536 MB
- SSD:          128GB
- Keyboard:     en_US
```

<a name="installation_description"></a>
### Installation description

- [Arch Linux with macOS](https://wiki.archlinux.org/title/Mac#Arch_Linux_with_macOS_or_other_operating_systems)
- [System encryption](https://wiki.archlinux.org/title/Dm-crypt)
- [Native Apple boot loader](https://wiki.archlinux.org/title/Mac#Using_the_native_Apple_boot_loader_with_systemd-boot_(Recommended))

<a name="procedure"></a>
### Procedure

<a name="pre_installation"></a>
#### Pre-installation

- [x] [Firmware update](https://wiki.archlinux.org/title/Mac#Firmware_updates)
- [x] [Disk partition](https://wiki.archlinux.org/title/Mac#Arch_Linux_with_macOS_or_other_operating_systems)
- [x] [Installation medium](https://wiki.archlinux.org/title/USB_flash_installation_medium)

<a name="installation"></a>
#### Installation
- Reboot and hold `alt`
- [Choose the live environment](https://wiki.archlinux.org/title/Installation_guide#Boot_the_live_environment) (`EFI boot`)

<a name="live_environment_configuration"></a>
#### Live environment Configuration

- [Setup the console keyboard layout](https://wiki.archlinux.org/title/Installation_guide#Set_the_console_keyboard_layout) (default: `en_US`)
  - >
```
ls /usr/share/kbd/keymaps/**/*.map.gz
loadkeys de-latin1
```
- [Verify the boot mode](https://wiki.archlinux.org/title/Installation_guide#Verify_the_boot_mode)
  - >
```
ls /sys/firmware/efi/efivars
// the command should shows the directory without error
```
- [Connect to the internet](https://wiki.archlinux.org/title/Installation_guide#Connect_to_the_internet)
  - >
```
ip link
iwctl
station <device> connect <SSID>
```
- [Update the system clock](https://wiki.archlinux.org/title/Installation_guide#Update_the_system_clock)
  - >
```
timedatectl set-ntp true
timedatectl status
```

#### Encryption

Expected result:
```
NAME                       MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINTS
sda                          8:0    0  113G  0 disk
├─sda1                       8:1    0  200M  0 part  /boot
├─sda2                       8:2    0 38.3G  0 part
└─sda3                       8:3    0 74.5G  0 part
  └─arch                   254:0    0 74.5G  0 crypt
    ├─arch-swap            254:1    0    8G  0 lvm   [SWAP]
    ├─arch-root            254:2    0   32G  0 lvm   /
    └─arch-home            254:3    0 34.5G  0 lvm   /home
sdb                          8:16   1  7.5G  0 disk
├─sdb1                       8:17   1  782M  0 part
└─sdb2                       8:18   1   13M  0 part
```

- [Secure erasure of the hard disk drive](https://wiki.archlinux.org/title/Dm-crypt/Drive_preparation#dm-crypt_wipe_on_an_empty_disk_or_partition)
  - >
```
// check which block-device should be wiped, for my case: block-device = sda3
lsblk
// Create a temporary encrypted container
cryptsetup open --type plain -d /dev/urandom /dev/<block-device> to_be_wiped
// Wipe the partition
dd if=/dev/zero of=/dev/mapper/to_be_wiped bs=1m status=progress
// Close the container
cryptsetup close to_be_wiped
```
- [Encrypting devices with LUKS mode](https://wiki.archlinux.org/title/Dm-crypt/Device_encryption#Encrypting_devices_with_LUKS_mode)
  - >
```
cryptsetup luksFormat /dev/<block-device>
cryptsetup open /dev/<block-device> lvm
pvcreate /dev/mapper/lvm
vgcreate arch /dev/mapper/lvm
lvcreate -L 8G arch -n swap
lvcreate -L 32G arch -n root
lvcreate -l 100%FREE arch -n home
```
- Format the disks
  - >
```
mkfs.ext4 /dev/arch/root
mkfs.ext4 /dev/arch/home
mkswap /dev/arch/swap
```
- Mount the file system
  - >
```
mount /dev/mapper/arch-root /mnt
mkdir /mnt/home
mount /dev/mapper/arch-home /home
swapon /dev/mapper/arch-swap
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
lsblk
```
- Base installation package
  - >
```
pacstrap -i /mnt base base-devel linux linux-firmware intel-ucode
pacstrap -i /mnt gvim lvm2 man-db man-pages iwd
```


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
```
HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt lvm2 filesystems fsck)
```
- /boot/loader/loader.conf
```
#timeout 3
#console-mode keep
default arch-*
```
- /boot/loader/entries/arch.conf
```
title		Arch Linux
linux		/vmlinuz-linux
initrd	/intel-ucode.img
initrd	/initramfs-linux.img
options	cryptdevice=/dev/sda3:arch::allow-discards root=/dev/mapper/arch-root rw
```
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
layout.css.devPixelsPerPx:

# xinitrc

```
#!/bin/sh

XRESOURCES=$HOME/.Xresources

if [ -f "$XRESOURCES" ]; then
	xrdb -merge ~/.Xresources
fi

xset r rate 200 25

exec i3
```

# .Xresources
```
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
```

# /etc/X11/xorg.conf.d/00-keyboard.conf
```
Section "InputClass"
        Identifier "system-keyboard"
        MatchIsKeyboard "on"
        Option "XkbOptions" "ctrl:nocaps"
EndSection
```

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
