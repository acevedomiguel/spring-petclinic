#!/bin/bash

# 042347819636.dkr.ecr.us-east-2.amazonaws.com/spring-petclinic
AWS_REGION=us-east-2
AWS_ECR=042347819636.dkr.ecr.us-east-2.amazonaws.com/spring-petclinic

if [ -z "$AWS_ECR" ]
then
    echo "Please copy the aws ecr path into the AWS_ECR variable in this script"
    exit 1
fi

# aws ecr get-login docker login –u AWS –p password –e none https://042347819636.dkr.ecr.us-east-2.amazonaws.com

aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ECR

docker build -t $AWS_ECR:latest .
docker push $AWS_ECR:latest
