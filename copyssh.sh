#!/bin/bash
for ip in `cat /root/list_of_servers`; do
    ssh-copy-id -i ~/.ssh/id_rsa.pub $ip
done
