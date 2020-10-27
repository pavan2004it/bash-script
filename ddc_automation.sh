if [[ $1 != '' ]]; then
	LICENSE_FILE=$1
else 
	if [[ -f "docker_subscription.lic" ]]; then
		LICENSE_FILE="$(pwd)/docker_subscription.lic"
	else
		echo "Could not detect a docker_subscription.lic file in the current folder."
		echo "Please run this script again and provide the path to your docker subscription license file, as follows:"
		echo "./ddc_evaluation.sh /path/to/docker_subscription.lic"
		exit 1
	fi
fi

LICENSE_FILE=$(printf "%q\n" "$LICENSE_FILE")
echo "Using Docker License located at: $LICENSE_FILE"

echo "Installing UCP"
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
	-e UCP_ADMIN_PASSWORD=ddcpassword \
	-v /home/docker/docker_subscription.lic:/docker_subscription.lic --name ucp \
	docker/ucp:2.1.3 install --host-address 10.99.14.24 --san 10.99.14.24--fresh-install \
	--swarm-port 8888 --controller-port 444 

UCP_URL=https://10.99.14.24:444

# Get the UCP CA
curl -k $UCP_URL/ca > ucp-ca.pem
echo "Installing DTR"
docker run -it --rm \
	docker/dtr:2.2.4 install \ 
	--ucp-url $UCP_URL \
	--dtr-external-url 10.99.14.24:443 \
	--ucp-username admin \
	--ucp-password ddcpassword \
	--ucp-ca "$(cat ucp-ca.pem)"

DTR_URL=https://10.99.14.24

echo "Configuring DTR to trust UCP"
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock --name ucp $UCP_IMAGE dump-certs --cluster -ca > ucp_root_ca.pem
DTR_CONFIG_DATA="{\"authBypassCA\":\"$(cat ucp_root_ca.pem | sed ':begin;$!N;s|\n|\\n|;tbegin')\"}"
curl -u admin:ddcpassword -k  -H "Content-Type: application/json" $DTR_URL/api/v0/meta/settings -X POST --data-binary "$DTR_CONFIG_DATA"

echo "Configuring UCP to use DTR"
wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
chmod +x /home/pavan/jq-linux64
TOKEN=$(curl -k -c jar https://10.99.14.24:444/auth/login -d '{"username": "admin", "password": "ddcpassword"}' -X POST -s | /home/pavan/jq-linux64 -r ".auth_token")
UCP_CONFIG_DATA="{\"url\":\"$DTR_URL\", \"insecure\":true }"
curl -k -s -c jar -H "Authorization: Bearer ${TOKEN}" $UCP_URL/api/config/registry -X POST --data "$UCP_CONFIG_DATA"
EOF

DTR_URL="https://10.99.14.24:443"
UCP_URL="https://10.99.14.24:444"

echo ""
echo ""
echo "Docker Datacenter Installation Completed"
echo "========================================================================="
echo "You may access Docker Datacenter at the following URLs:"
echo ""
echo "Docker Universal Control Plane: $UCP_URL"
echo "Docker Trusted Registry: $DTR_URL"
echo ""
echo "- Admin Username: admin"
echo "- Admin Password: ddcpassword"
echo ""
echo "The Docker Trusted Registry can be accessed as a registry at 10.99.14.24"
echo ""
echo "The certificates used to sign UCP and DTR will not be trusted by your browser."

echo "========================================================================"
