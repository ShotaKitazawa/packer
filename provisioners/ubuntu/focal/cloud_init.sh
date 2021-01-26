#!/bin/bash

apt install -y cloud-init cloud-initramfs-growroot

systemctl enable cloud-init

# enable root login
sed -i -e 's|^\(disable_root:\).*$|\1 0|g' /etc/cloud/cloud.cfg

