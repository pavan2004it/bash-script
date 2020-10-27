#!/bin/bash

echo -e "o\nn\np\n1\n\n\nw" | fdisk /dev/sdd

mkfs.ext4 -L datapartition /dev/sdd1

mkdir /mnt/newwvar

mount /dev/sdd1 /mnt/newwvar

cd /var

cp -ax * /mnt/newwvar

cd /

mv var var.old

mkdir /var

umount /dev/sdd1

mount /dev/sdd1 /var



