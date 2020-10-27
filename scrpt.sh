# !/bin/bash

mkdir -p /var/empty/sshd
chown root:roo /var/empty/sshd
chmod 744 /var/empty/sshd

systemctl restart sshd.service

systemctl status sshd.service >> /var/log/boot.log



exit