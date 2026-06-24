#!/bin/bash

########################
# NVR INSTALLER SCRIPT #
########################

echo "===================================="
echo "Installing NVR..."
echo "===================================="
source .cctv_configuration.env
FSTAB_ENTRY="//${NAS_IP}/${NAS_SHARENAME} /mnt/cctv_storage cifs credentials=/srv/NVR/.cctv_configuration.env,iocharset=utf8,nofail,x-systemd.automount,x-systemd.mount-timeout=30,_netdev,uid=0,gid=0 0 0"
apt update
apt install cifs-utils ffmpeg -y
mkdir -p /srv/NVR/
mkdir -p /mnt/cctv_storage/
useradd -M -s /usr/sbin/nologin cctv
cp cctv.service /etc/systemd/system/
cp .cctv_configuration.env /srv/NVR/
chmod 600 /srv/NVR/.cctv_configuration.env
cp cctv.sh /srv/NVR/
chmod 750 /srv/NVR/cctv.sh
chown -R cctv:cctv /srv/NVR/
if ! grep -q "/mnt/cctv_storage" /etc/fstab; then
    echo "# NVR FSTAB ENTRY:" >> /etc/fstab
    echo "$FSTAB_ENTRY" >> /etc/fstab
    echo "FSTAB configuration updated."
fi
systemctl daemon-reload
mount -a
systemctl enable cctv.service
systemctl start cctv.service
echo "=========================================="
echo "NVR installation completed!" 
echo "Remember to add your crontab for cleaning!"
echo "=========================================="
