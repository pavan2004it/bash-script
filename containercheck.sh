#!/bin/bash

CONTAINER_NAME='scheduleworkerrole'
# Checking if docker container with $CONTAINER_NAME name exists.
COUNT=$(docker ps | grep "$CONTAINER_NAME" | wc -l)
if (($COUNT > 0)); then
        echo 'scheduleworkerrole container exists'
		docker rm $(docker ps -a -f status=exited -q)

else
        # cleanup

        echo "Removing exited containers"
        docker rm $(docker ps -a -f status=exited -q)
        echo "Cleanup complete"
        echo "Starting $CONTAINER_NAME container"
  # run your container
        docker run -d --name scheduleworkerrole -e WorkerRoleScheduler=60000 -e FeedService:BaseUrl=http://internal-clinfeed-alb-dev-483547670.us-east-1.elb.amazonaws.com:7000/ -e  MessageBroker:BaseUrl=http://internal-clinfeed-alb-dev-483547670.us-east-1.elb.amazonaws.com:5000/ -t 672985825598.dkr.ecr.us-east-1.amazonaws.com/fls/scheduleworkerrole:latest
        if (( $? == 0 ));then
                echo "$CONTAINER_NAME Started successfully"
        else
                echo "$CONTAINER_NAME failed"
        fi

fi