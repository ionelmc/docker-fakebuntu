#!/bin/sh -eux
systemd --version

mkdir -p /root/.ssh
cp /host-id_rsa.pub /root/.ssh/authorized_keys
chown root -R /root/.ssh
chmod go-wx -R /root/.ssh

storage_path=/storage$(DOCKER_HOST=unix:///host-docker.sock docker inspect -f '{{ .Name }}' $(hostname))
mkdir -p $storage_path
ln -sf $storage_path /var/lib/docker
exec "$@"
