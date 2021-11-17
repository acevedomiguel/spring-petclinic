#!/bin/bash

# 042347819636.dkr.ecr.us-east-2.amazonaws.com/spring-petclinic
AWS_ECR=""
AWS_REGION=""
ECS_CLUSTER_NAME=""
ECS_SERVICE_NAME=""

if [ -z "$AWS_ECR" ]
then
    echo "Please copy the aws ecr path into the AWS_ECR variable in this script"
    exit 1
fi

if [ -z "$AWS_REGION" ]
then
    # if not setup, get ir from ECR url
    arrECR=(${AWS_ECR//./ })
    AWS_REGION=${arrECR[3]}
fi


echo $AWS_REGION

echo "Login to ECR"
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ECR

echo "Build and push image"
docker build -t $AWS_ECR:latest .
docker push $AWS_ECR:latest


if [ -z "$ECS_CLUSTER_NAME" ] || [ -z "$ECS_SERVICE_NAME" ]
then
    echo "Without this information you will need to update the deployment on ECS manually"
    exit 1
else 
    echo "Updating ecs deployment"
    aws ecs update-service --cluster $ECS_CLUSTER_NAME --service $ECS_SERVICE_NAME --force-new-deployment
fi
