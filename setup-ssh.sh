#!/usr/bin/env bash
set -e
apt-get install -y openssh-server
mkdir /var/run/sshd
echo 'root:$SALT_PASSWORD' |chpasswd
sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
