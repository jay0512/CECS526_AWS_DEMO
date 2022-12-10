#!/usr/bin/env bash

# export DOCKER_VERSION=${DOCKER_VERSION:-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)} # force redeployment on changes
export DOCKER_VERSION=${DOCKER_VERSION:-V1} # force redeployment on changes
export DOCKER_IMAGE=${DOCKER_IMAGE:-jaypatel05/aws-blog-demo}:$DOCKER_VERSION

echo "DOCKER_IMAGE: $DOCKER_IMAGE"
echo "DOCKER_VERSION: $DOCKER_VERSION"

echo "  > Steps to perform:"
echo "  >  1. build & push Docker container                 [container stack] - $DOCKER_IMAGE"
echo "  >  2. build & deploy SAM / CloudFormation stack     [both stacks]"
echo "  >  3. get output URLs, save to file                 [both stacks]"
echo "  >  4. open/upload static website                    [both stacks]"

## Build & push docker container
docker build -t $DOCKER_IMAGE .
docker push $DOCKER_IMAGE

## Build & deploy full stack
sam build
sam deploy --parameter-overrides "ParameterKey=DockerImage,ParameterValue=$DOCKER_IMAGE"

## Save URLs
RAW_OUTPUTS=$(aws cloudformation describe-stacks --stack-name aws-blog-demo --query "Stacks[0].Outputs")
echo $RAW_OUTPUTS
echo "let urls = $RAW_OUTPUTS" > html/urls.js

## Open the demo file
echo "SUCCESS!"
echo "Now open or refresh file://$PWD/html/index.html"
