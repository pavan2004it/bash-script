#!/bin/bash

pvcreate /dev/sdc

vgcreate docker /dev/sdc

lvcreate --wipesignatures y -n thinpool docker -l 95%VG

lvcreate --wipesignatures y -n thinpoolmeta docker -l 1%VG

lvconvert -y --zero n -c 512K --thinpool docker/thinpool --poolmetadata docker/thinpoolmeta

cat > /etc/lvm/profile/docker-thinpool.profile <<EOM
activation {
  thin_pool_autoextend_threshold=80
  thin_pool_autoextend_percent=20
}
EOM

lvchange --metadataprofile docker-thinpool docker/thinpool

lvs -o+seg_monitor

mkdir /var/lib/docker.bk

mv /var/lib/docker/* /var/lib/docker.bk

cat > /etc/docker/daemon.json <<EOM
{
    "storage-driver": "devicemapper",
    "storage-opts": [
    "dm.thinpooldev=/dev/mapper/docker-thinpool",
    "dm.use_deferred_removal=true",
    "dm.use_deferred_deletion=true"
    ]
}
EOM

systemctl start docker

docker info

rm -rf /var/lib/docker.bk
