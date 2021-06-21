#!/bin/bash

# Upgrade OS
apt -y update
apt -y dist-upgrade

# Remove fat packages
dpkg --list | awk '{ print $2 }' | grep linux-source | xargs apt remove -y --purge
dpkg --list | awk '{ print $2 }' | grep build-essential | xargs apt remove -y --purge

# Make sure udev does not block our network - http://6.ptmc.org/?p=164
echo "==> Cleaning up udev rules"
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

echo "==> Cleaning up leftover dhcp leases"
if [ -d "/var/lib/dhcp" ]; then
    rm /var/lib/dhcp/*
fi

echo "==> Cleaning up tmp"
rm -rf /tmp/*

# Cleanup apt cache
apt -y autoremove --purge
apt -y autoclean
apt -y clean

echo "==> Installed packages"
dpkg --get-selections | grep -v deinstall

DISK_USAGE_BEFORE_CLEANUP=$(df -h)

# Remove Bash history
unset HISTFILE
rm -f /root/.bash_history
rm -f /home/${SSH_USER}/.bash_history

# Clean up log files
find /var/log -type f | while read f; do echo -ne '' > "${f}"; done;

echo "==> Clearing last login information"
>/var/log/lastlog
>/var/log/wtmp
>/var/log/btmp

# Whiteout root
count=$(df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}')
count=$(expr $count - 1)
dd if=/dev/zero of=/tmp/whitespace bs=1024 count=$count
rm /tmp/whitespace

# Whiteout /boot
count=$(df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}')
count=$(expr $count - 1)
dd if=/dev/zero of=/boot/whitespace bs=1024 count=$count
rm /boot/whitespace

# Zero out the free space to save space in the final image
dd if=/dev/zero of=/EMPTY bs=1M  || echo "dd exit code $? is suppressed"
rm -f /EMPTY

# Make sure we wait until all the data is written to disk, otherwise
# Packer might quite too early before the large files are deleted
sync
sync
sync

echo "==> Disk usage before cleanup"
echo ${DISK_USAGE_BEFORE_CLEANUP}

echo "==> Disk usage after cleanup"
df -h
