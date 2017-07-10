#!/bin/sh -eux
exec 3>&1
mkdir -p /root/.ssh
cp /id_rsa.pub /root/.ssh/authorized_keys
chown root -R /root/.ssh
chmod go-wx -R /root/.ssh
mkdir -p /storage/$(hostname)
ln -sf /storage/$(hostname) /var/lib/docker
exec "$@"
