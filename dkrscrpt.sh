#!/bin/bash
sh -c 'echo "https://storebits.docker.com/ee/rhel/sub-6e152c87-1e0e-4ab3-843d-3017ab08e90c" > /etc/yum/vars/dockerurl'
sh -c 'echo "7.3" > /etc/yum/vars/dockerosversion'
yum-config-manager \
    --add-repo \
    https://storebits.docker.com/ee/rhel/sub-6e152c87-1e0e-4ab3-843d-3017ab08e90c/rhel/docker-ee.repo
yum makecache fast
yum -y install docker-ee
systemctl start docker
systemctl enable docker
systemctl stop docker
