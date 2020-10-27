#!/bin/bash
source env.sh
eval "$(aws ecr get-login --no-include-email --region us-east-1)"
eval "$(docker push 672985825598.dkr.ecr.us-east-1.amazonaws.com/clinfeedui:latest)"