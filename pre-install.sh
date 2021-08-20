#!/bin/sh

# This script will automate as mush as possible before changing the root directory.
# Run this after having properly mounted the partitions for your installation.
# You must also have a working internet connection.

source ./prefs.sh &> /dev/null || print "No preferences found"

basepkgs="base base-devel linux grub runit elogind-runit networkmanager networkmanager-runit git $editor $shell $posix"
uefi=0 # Assume uefi by default

# Change the editor to vi if vim isn't installed
# This is temporary, the chosen editor will still be installed
which "$editor" &> /dev/null || editor="vi"

# Edit the mirrorlist now for better speeds
$editor /etc/pacman.d/mirrorlist

# Add proprietary drivers if desired
proprietary && basepkgs="$basepkgs linux-firmware"

# Check if the system actually is uefi
ls /sys/firmware/efi/efivars &> /dev/null || uefi=1

# Add uefi components to basepkg (but only if needed)
$uefi && basepkgs="$basepkgs efibootmgr"

# Install the system
basestrap /mnt "$basepkgs"

# Configure the fstab
fstabgen -U /mnt >> /mnt/etc/fstab

# Copy this installer to the main machine to resume installation
cp "$(pwd)" /mnt/root/
