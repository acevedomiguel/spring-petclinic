# Engerybox Devops

I attached the files I created for this test [spring-petclinic.zip](spring-petclinic.zip), or you can pull the project I forked to test all together: https://github.com/acevedomiguel/spring-petclinic

I used ECS for deployment since your company uses it but I have no experience using it, so I will give it a try.

## Requirements
* Docker daemon running (to build and dockerize the project)
* AWS keys configured with permission to create the infrastructure (for simplicity it will use the default profile on `~/.aws/credentials`)
* Latest terraform installed

## Installation
Unzip the files on the root folder of the demo project (not necessary for terraform but good to have all in the same place)

### Define region to create
Update the file `/terraform/versions.tf` to define the default region for the resources, and can also set up the AWS if you don't want to use the default ones.


```terraform
provider "aws" {
  region = "us-east-2"
  # access_key = "my-access-key"
  # secret_key = "my-secret-key"
}
```

### Create the infrastructure with terraform
```bash
cd terraform/
terraform plan
terraform apply
```

### Output
After apply, the output will give information to update the build script (`build.sh`) later:
```
  + AWS_ECR          < ECR where the dockerize image will be uploaded
  + ECS_CLUSTER_NAME < ECS cluster name created
  + ECS_SERVICE_NAME < ECS service name created
  + load_balancer_ip < URL/IP to access the site
```

When destroying the infra I found an issue, sometimes you need to go to the ECS console and stop the current task otherwise terraform will keep waiting forever.

### Update build script
Whit the infra information please update the `build.sh` script, assign the ECR and ECS information to make the build and deploy

```bash
AWS_ECR="" 
AWS_REGION="" # optional, will try to guess it from the ECR URL
ECS_CLUSTER_NAME=""
ECS_SERVICE_NAME=""
```

### Updating the project code
Once created the infra and updated the build script can be free to modify the code.

Once updated can just run the build code:
```bash
./build.sh
```

## About the files
### Terraform
This will be a simple explanation of the tf files, how to split could be a never ending discussion, I just tried to tied them up by functionality

| Files     | Short Description           |
| --------- |:-------------|
| `variables.tf` | I just allow the number of instances, could be more options but I didn't want to overengineer.
| `ecr.tf` | Create the ECR where to push the docker image
| `ecs.tf` | Creates the cluster, the service name, the task
| `gateway.tf` | internet internet gateway, nat gateway, routing, and elastic ip.
| `loadbalancer.tf` | Load balancer and target group to the ECS tasks
| `main.tf` | VPC and AZ
| `policyrole.tf` | role and policy for the ECS task and task executor.
| `securitygroup.tf` | security rules for the load balancer access and the communication between the LB and the task
| `subnets.tf` | creates 2 public subnets and 2 private subnets
| `versions.tf` | AWS configuration and terraform versions

### Docker
Multistage docker, after building it will use an alpine version to run the jar file.

I put the name of the JAR file name on the entry point and changing the version will require to change the Dockerfile:
* one option will be to create and script to get the latest build jar 
* or for second option I know the Dockerfile can be created from the JAVA project instead of having a Dockerfile.

### Build script
Just in a few words what the script it's doing:
* Using the information from the infra (if not using terraform still can assign any other existing AWS infra)
* First check the required variables to run otherwise will fail
* Login to docker using AWS credential (required to push to ECR)
* Docker build and push to ECR
* With the ECS information it will update teh deploy to get the latest build

## Comments
* In an ideal scenario terraform should use it’s own keays with it’s own permissions.
* No `build.sh` script, I always prefer a proper CI/CD, there are a lot of hardcoded values, not a visible status of the pipeline when working with a team, it was actually harder for me to do this way.
* The terraform options (`values.tf`) it’s kept at the minimum, should be discussed and what values should be parametric.
* I missed the autoscaling for ECS, since I have no experience. I still had some to learn there and I didn’t want to hack it or just copy and paste, this is what I could do in the the time dedicated to the test, hope is still enough.

