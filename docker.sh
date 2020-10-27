#!/bin/bash

yum update -y

yum install -y docker



systemctl start docker

systemctl enable docker

firewall-cmd --zone=public --add-port=22/tcp --permanent

firewall-cmd --zone=public --add-port=2375/tcp --permanent

firewall-cmd --zone=public --add-port=2376/tcp --permanent

firewall-cmd --zone=public --add-port=2377/tcp --permanent

firewall-cmd --reload


mkdir -p /etc/systemd/system/docker.service.d

cat > /etc/systemd/system/docker.service.d/custom.conf <<EOM
[Service]
Environment="DOCKER_OPTS=-H=$dockerip:2376 -H unix:///var/run/docker.sock --tlsverify --tlscacert=/etc/docker/ssl/ca.pem --tlscert=/etc/docker/ssl/cert.pem --tlskey=/etc/docker/ssl/key.pem"
EOM

set -e
set -x

DAYS=1825
PASS=$(openssl rand -hex 16)

# remove certificates from previous execution.
rm -f *.pem *.srl *.csr *.cnf


# generate CA private and public keys
echo 01 > ca.srl
openssl genrsa -des3 -out ca-key.pem -passout pass:$PASS 2048
openssl req -subj '/CN=$dockerhost/' -new -x509 -days $DAYS -passin pass:$PASS -key ca-key.pem -out ca.pem

# create a server key and certificate signing request (CSR)
openssl genrsa -des3 -out server-key.pem -passout pass:$PASS 2048
openssl req -new -key server-key.pem -out server.csr -passin pass:$PASS -subj '/CN=$dockerhost/'

echo subjectAltName = DNS:=$dockerhost,IP:$dockerip,IP:127.0.0.1 > extfile.cnf

# sign the server key with our CA
openssl x509 -req -days $DAYS -passin pass:$PASS -in server.csr -CA ca.pem -CAkey ca-key.pem -out server-cert.pem -extfile extfile.cnf

# create a client key and certificate signing request (CSR)
openssl genrsa -des3 -out key.pem -passout pass:$PASS 2048
openssl req -subj '/CN=client' -new -key key.pem -out client.csr -passin pass:$PASS

# create an extensions config file and sign
echo extendedKeyUsage = clientAuth > extfile.cnf
openssl x509 -req -days $DAYS -passin pass:$PASS -in client.csr -CA ca.pem -CAkey ca-key.pem -out cert.pem -extfile extfile.cnf

# remove the passphrase from the client and server key
openssl rsa -in server-key.pem -out server-key.pem -passin pass:$PASS
openssl rsa -in key.pem -out key.pem -passin pass:$PASS

# remove generated files that are no longer required
rm -f ca-key.pem ca.srl client.csr extfile.cnf server.csr

mkdir -p /etc/docker/ssl

cp server-cert.pem server-key.pem ca.pem /etc/docker/ssl/

cat > /usr/lib/systemd/system/docker.service <<EOM
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target docker-telemetry.service

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd -H $dockerhost:2376 --tlsverify --tlscacert=/etc/docker/ssl/ca.pem --tlscert=/etc/docker/ssl/server-cert.pem --tlskey=/etc/docker/ssl/server-key.pem
ExecReload=/bin/kill -s HUP $MAINPID
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
# Uncomment TasksMax if your systemd version supports it.
# Only systemd 226 and above support this version.
#TasksMax=infinity
TimeoutStartSec=0
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process
# restart the docker process if it exits prematurely
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s

[Install]
WantedBy=multi-user.target
EOM

systemctl daemon-reload
systemctl restart docker



exit 0