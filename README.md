# Automated resource allocation for serverless containers in the Edge

The project represents the use of Serverless Functions and the Serverless Containers. The term “serverless containers” refers to technologies that enable cloud users to run containers, but outsource the effort of managing the actual servers or computing infrastructure they are running on. Whereas, Serverless functions are a single-purpose, programmatic feature of serverless computing — also simply called “serverless” — a cloud computing execution model where the cloud provider provisions computing resources on demand for its customers and manages all architectures, including cloud infrastructure.


AWS CloudFormation is a service that gives developers and businesses an easy way to create a collection of related AWS and third-party resources, and provision and manage them in an orderly and predictable fashion. CloudFormation creates a bucket for each region in which you upload a template file. The buckets are accessible to anyone with Amazon Simple Storage Service (Amazon S3) permissions in your AWS account. If a bucket created by CloudFormation is already present, the template is added to that bucket.

The project contains Flask App for calling GET, POST, PUT DELETE calls. The application handles blogs using AWS DynamoDB. 


### Installation before code run
- Install `Docker`
- Install the `AWS CLI`
- Install the `AWS SAM CLI`

### Run Application from CLI
- Build AWS build using SAM CLI: `sam build`
- After building AWS SAM build, we need to perform guided deploy: `sam deploy --guided`
  It will ask for sam configuration
  
  ```
    Configuring SAM deploy
    ======================

        Looking for config file [samconfig.toml] :  Found
        Reading default arguments  :  Success

        Setting default arguments for 'sam deploy'
        =========================================
        Stack Name [aws-blog-demo]: aws-blog-demo
        AWS Region [us-west-1]: us-west-1
        Parameter DockerImage [jaypatel05/aws-blog-demo:V1]: jaypatel05/aws-blog-demo:V1
        #Shows you resources changes to be deployed and require a 'Y' to initiate deploy
        Confirm changes before deploy [Y/n]: Y
        #SAM needs permission to be able to create roles to connect to the resources in your template
        Allow SAM CLI IAM role creation [Y/n]: Y
        #Preserves the state of previously provisioned resources when an operation fails
        Disable rollback [Y/n]: Y
        GetBlogs may not have authorization defined, Is this okay? [y/N]: y
        GetBlog may not have authorization defined, Is this okay? [y/N]: y
        PostBlog may not have authorization defined, Is this okay? [y/N]: y
        DeleteBlog may not have authorization defined, Is this okay? [y/N]: y
        Save arguments to configuration file [Y/n]: Y
        SAM configuration file [samconfig.toml]: samconfig.toml
        SAM configuration environment [default]: default


        Deploying with following values
        ===============================
        Stack name                   : aws-blog-demo
        Region                       : us-west-1
        Confirm changeset            : True
        Disable rollback             : True
        Deployment s3 bucket         : aws-sam-cli-managed-default-samclisourcebucket-w4ko9cdw65v7
        Capabilities                 : ["CAPABILITY_IAM"]
        Parameter overrides          : {"DockerImage": "jaypatel05/aws-blog-demo:V1"}
        Signing Profiles             : {}
  ```

### Deploy Docker container locally and push it to the dockerhub
```
export TABLE_NAME=$ServerlessBlog
docker build -t aws-blog-demo .
docker run -it -p 5000:80 -v $PWD/src:/app -v ~/.aws:/root/.aws -e TABLE_NAME aws-blog-demo
docker push aws-blog-demo
```

Note: You need to generate `credentials` file where you need to define `aws_access_key_id` and `aws_secret_access_key` for running the docker container with AWS API Gateway calls.

After deployment of docker, we need to run deploy script.
`./deploy.sh`

The Result after the Deploy script:
```
------------------------------------------------------------------------------------------------------
CloudFormation outputs from deployed stack
------------------------------------------------------------------------------------------------------
Outputs
------------------------------------------------------------------------------------------------------
Key                 ContainersURL                                                    
Description         URL for load balancer (Fargate containers) endpoint                                                                                                                                                                                                  
Value               http://aws-b-Farga-G14ON5ZPPEBT-477843759.us-west-1.elb.amazonaws.com

Key                 FunctionsURL                                                                                                                                                                                                                                         
Description         URL for API gateway (Lambda functions) endpoint                                                                                                                                                                                                      
Value               https://nwd9e79fg2.execute-api.us-west-1.amazonaws.com/Prod                                                                                                                                                                                          
------------------------------------------------------------------------------------------------------
```

## Architecture of the Flask Blog Application

The project perform same API calls using 2 different methodology. 1.) AWS Lambda Functions with an API Gateway 2.) AWS Fargate containers with Load Balancers.

Project has very plain HTML UI with blog display, post and delete functionality. The UI provides options to choose either Serverless Functions URL or Serverless Containers.


Below diagram shows detailed figure of AWS Services stack with two different paths and UI For the Application.