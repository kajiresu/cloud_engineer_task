# Analysis Deployment

## Prerequisites

- aws account
- aws cli
- docker

## Steps

1. Prepare the Python Script:
    - Ensure that the Python script is ready, code changes etc.
    - Dependencies are listed in requirements.txt.
    - Note: 
        - Fixed usage, files are tsv not txt as referenced within the script.
    - Option:
        - Modify script to use data source of S3.
        - Decide on output of data.
            - S3, SQL DB etc.
1. Create a Docker Image:
    - A Dockerfile for the Python environment.
        - This version stores the files within the image, this is okay for testing purposes only.
        - Files are within the data folder.
    - Change directory to the root of the analysis folder
        - `cd path/analysis`
    - Build the Docker image.
        - `docker image build -t analysis-processing:0.0.1 ./`
    - Test the Docker image locally.
        - `docker run analysis-processing:0.0.1`
1. Configure AWS access
    - Install AWS CLI and run:
        - `aws configure`
1. Push the Docker Image to Amazon ECR:
    - Create an ECR repository.
        - `aws ecr create-repository --repository-name analysis-processing`
        - `aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 123456790.dkr.ecr.eu-west-1.amazonaws.com`
    - Push the image to ECR.
        - `docker tag analysis-processing:0.0.1 123456790.dkr.ecr.eu-west-1.amazonaws.com/analysis-processing:0.0.1`
        - `docker push 123456790.dkr.ecr.eu-west-1.amazonaws.com/analysis-processing:0.0.1`
1. Option: 
    - Upload Data to S3:
        - Store large input files in an S3 bucket.
1. Set Up ECS and Fargate:
    - Create an ECS cluster.
        - `aws ecs create-cluster --cluster-name analysis-processing-cluster`
    - Define an ECS task that runs the Docker image from ECR.
        - Located within aws `task.json`
        - `aws ecs register-task-definition --cli-input-json file://aws/task.json`
    - Option:
        - Create ECS execution role if it was not created
            - `aws iam create-role --role-name ecsTaskExecutionRole --assume-role-policy-document file://aws/policy.json`
    - Option:
        - Set up permissions to access S3 and run the task in Fargate.
1. Trigger and Monitor the Task:
    - Run the task manually or automate using AWS SDK/CLI.
        -  ` aws ecs run-task \
  --cluster analysis-processing-cluster \
  --launch-type FARGATE \
  --task-definition data-processing \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-12345],securityGroups=[sg-12345],assignPublicIp=ENABLED}`
    - Option: 
        - Get subnet and security groups
            - `aws ec2 describe-subnets`
            - `aws ec2 describe-security-groups`
    - Use CloudWatch to monitor the task execution.
        - Option: 
            - Use task ID from run-task to monitor process:
                - `aws ecs describe-tasks --cluster my-ecs-cluster --tasks []`

## Notes / Improvements

1. Decided to containerise the script, this will allow for an isolated environment and if required scaling.
1. Data files are built within the image, this is only for testing purposes, a storage solution would be required.
1. The use of Fargate was to keep the deployment of the docker container simple and is serverless.
1. Consider enabling ECS auto-scaling.
1. Consider using S3 storage for large files.
1. Consider adapting to a GitHub Action pipeline.
    - Using a GitHub repo we can introduce collaboration, review changes and automate versioning of the app.
    - The pipeline can handle the creation of the docker image, deploying to ECR and ECS.
    - Notifications can be sent should the build fail.
1. Implement versioning of the container images.
1. Create gitignore to exclude data files.