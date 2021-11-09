#!/bin/bash

if [ "$#" -lt 1 ]; then
  echo "Missing TAG parameter"
  exit 1
else
  TAG=$1
fi

docker login

DOCKER_HUB_ACCOUNT=valdomar
DOCKER_FILE_NAME=Dockerfile
MAIN_IMAGE_NAME=android-sdk-js
MAIN_IMAGE_DIR=.
TAG_LATEST=latest

# extract base image name and tag from Dockerfile
regex_name_and_tag='FROM[[:blank:]]([^:]*):([^:]*)'
base_info=$(grep "^FROM[[:blank:]][^:]*:[^:]*" $MAIN_IMAGE_DIR/$DOCKER_FILE_NAME)
if [[ $base_info =~ $regex_name_and_tag ]]; then
  BASE_IMAGE_NAME=${BASH_REMATCH[1]}
  BASE_IMAGE_TAG=${BASH_REMATCH[2]}
fi

echo "Pulling the latest base image..."
docker pull $BASE_IMAGE_NAME:$BASE_IMAGE_TAG

echo "Building the main image..."
docker build -t $MAIN_IMAGE_NAME .

main_image_id=$(docker images $MAIN_IMAGE_NAME | awk '{if (NR!=1) {print $3}}')
echo "Built main image ID is: $main_image_id"

echo "Tagging the main image with $TAG..."
docker tag $main_image_id $DOCKER_HUB_ACCOUNT/$MAIN_IMAGE_NAME:$TAG
docker tag $main_image_id $DOCKER_HUB_ACCOUNT/$MAIN_IMAGE_NAME:$TAG_LATEST

echo "Pushing the main image to Docker Hub..."
docker push $DOCKER_HUB_ACCOUNT/$MAIN_IMAGE_NAME:$TAG
docker push $DOCKER_HUB_ACCOUNT/$MAIN_IMAGE_NAME:$TAG_LATEST
