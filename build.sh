#!/bin/bash

# 042347819636.dkr.ecr.us-east-2.amazonaws.com/spring-petclinic
ECR=""

if [ -z "$ECR" ]
then
    echo "Please copy the aws ecr path into the ECR variable in this script"
    exit 1
fi

# ECR login

docker build -t $ECR .
docker push $ECR