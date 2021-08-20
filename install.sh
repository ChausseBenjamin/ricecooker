#!/bin/sh

source ./prefs.sh

# Defaults (if they aren't set previously)
[ -z $hostname ]  && hostname="hostname"
[ -z $user ]      && user="master"
[ -z $groups ]    && groups="wheel"
[ -z $posix ]     && posix="bash"
[ -z $shell ]     && shell="bash"
[ -z $locales ]   && locales="en_US"
[ -z $timezone ]  && timezone="America/Toronto"
[ -z $uefi ]      && uefi=0
# [ -z $<++> ]     && <++>=<++>

# Double checking parameters:
# Check if uefi or not
ls /sys/firmware/efi/efivars &> /dev/null || uefi=1
# Check if shells are installed
which $posix &> /dev/null || shell="bash"
which $shell &> /dev/null || shell="bash"

# Configuring the timezone
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
# Update hardware clock
hwclock --systohc

# Configuring locales
for lang in $locales; do
  sed -i "s/.$lang/$lang/g" /etc/locale.gen
done
locale-gen
echo $locale | sed "s/\(.*\)\s.*$/LANG=\1.UTF-8" > /etc/locale.conf

# You love canday don't you?
sed -i "s/\(\[options\]\)/\1\nILoveCandy\nColor"

# Setup hostname
echo "$hostname" > /etc/hostname
sed "s/myhostname/$hostname/g" ./hosts > /etc/hosts

# Setup preferred posix shell
ln -sf "$(which $posix)" /usr/bin/sh

# Start NetworkManager at startup
ln -s /etc/runit/sv/NetworkManager/ /etc/runit/runsvdir/current

# Configure the grub command for a uefi system
grubcfg="--target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB"
# Verify the system is indeed uefi
ls /sys/firmware/efi/efivars &> /dev/null || uefi=1
# Change the grubcfg command if it is not the case
chck $uefi || grubcfg="--recheck /dev/$( lsblk -l | grep boot | sed "s/\s.*//g")"

# Install grub
grub-install "$grubcfg"
grub-mkconfig -o /boot/grub/grub.cfg

# Finishing touches
clear && echo Installation should be complete...
echo The last step is for you to configure your root password.
