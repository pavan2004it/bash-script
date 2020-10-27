#!/bin/bash

CONTAINER_NAME='approvalservice'
# Checking if docker container with $CONTAINER_NAME name exists.
COUNT=$(docker ps | grep "$CONTAINER_NAME" | wc -l)
if (($COUNT > 0)); then
    echo 'approvalservice container exists'
        # cleanup
else
  docker rm approvalservice
  # run your container
  docker run -d --network=clinfeed_network --name approvalservice -p 9000:9000  --log-driver=fluentd -e ASPNETCORE_ENVIRONMENT=$(ASPNETCORE_ENVIRONMENT) -e StorageService:BaseUrl=http://storageservice:3000/api/StorageService/ -e MessageBroker:BaseUrl=http://messagebroker:5000/api/messagebroker --restart unless-stopped -t flsdockercontainerregistry.azurecr.io/fls/approvalservice:$(Build.BuildNumber)

fi

