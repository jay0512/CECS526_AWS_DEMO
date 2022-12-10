# Automated resource allocation for serverless containers in the Edge

The project represents the use of Serverless Functions and Serverless Containers. The term “serverless containers” refers to technologies that enable cloud users to run containers, but outsource the effort of managing the actual servers or computing infrastructure they are running on. Whereas, Serverless functions are a single-purpose, programmatic feature of serverless computing — also simply called “serverless” — a cloud computing execution model where the cloud provider provisions computing resources on demand for its customers and manages all architectures, including cloud infrastructure.


AWS CloudFormation is a service that gives developers and businesses an easy way to create a collection of related AWS and third-party resources, and provision and manages them in an orderly and predictable fashion. CloudFormation creates a bucket for each region in which you upload a template file. The buckets are accessible to anyone with Amazon Simple Storage Service (Amazon S3) permissions in your AWS account. If a bucket created by CloudFormation is already present, the template is added to that bucket.

The project contains Flask App for calling GET, POST, and PUT DELETE calls. The application handles blogs using AWS DynamoDB. 


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

### Deploy the Docker container locally and push it to the docker hub
```
export TABLE_NAME=$ServerlessBlog
docker build -t aws-blog-demo .
docker run -it -p 5000:80 -v $PWD/src:/app -v ~/.aws:/root/.aws -e TABLE_NAME aws-blog-demo
docker push aws-blog-demo
```

Note: You need to generate `credentials` file where you need to define `aws_access_key_id` and `aws_secret_access_key` for running the docker container with AWS API Gateway calls.

After the deployment of docker, we need to run the deploy script.
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
The Deploy scripts update the `urls.js` with the ContainersURL and FunctionsURL so that the HTML page can give options to choose the backend for further network calls.

https://user-images.githubusercontent.com/26021273/206849660-e5301221-faa3-4a8f-9015-3a7605c26d98.mp4
[Video: Steps for the deployment]

## The architecture of the Flask Blog Application

The project performs the same API calls using 2 different methodologies. 1.) AWS Lambda Functions with an API Gateway 2.) AWS Fargate containers with Load Balancers.

The project has a very plain HTML UI with blog display, post, and delete functionality. The UI provides options to choose either Serverless Functions URL or Serverless Containers.


The below diagram shows a detailed figure of the AWS Services stack with two different paths and UI For the Application.

![AOSFinalProjectDiagram drawio](https://user-images.githubusercontent.com/26021273/206849451-1b745ffb-f2a1-4c2f-9ef2-41a62d405466.png)
[ Figure: Flask Blog Application Architecture for Serverless Functions and Serverless Containers ]

The repository contains two backends written in `functions.py` and `containers.py`. Both python codes are written for handling serverless functions and serverless containers respectively. Both python codes internally call `common.py` which contains all functions that handle AWS DynamoDB operations for add, update, and delete functionality in the NoSQL database.

![SS1](https://user-images.githubusercontent.com/26021273/206849467-0a8289c8-cfed-4dbf-a3ce-329740bb9442.png)
[ Figure: Plain UI with getBlogs call ]

### AWS Lambda Functions

With AWS Lambda, you can run code without provisioning or managing servers. You pay only for the compute time that you consume—there's no charge when your code isn't running. You can run code for virtually any type of application or backend service—all with zero administration. Just upload your code and Lambda takes care of everything required to run and scale your code with high availability. You can set up your code to automatically trigger from other AWS services or call it directly from any web or mobile app.

Here, we have created four different lambda functions for handling Blog API requests.
```
1. aws-blog-demo-GetBlogs
2. aws-blog-demo-GetBlog
3. aws-blog-demo-PostBlog
4. aws-blog-demo-DeleteBlog
```

The Monitoring tab will show seven CloudWatch metrics: Invocations, Duration, Error count and success rate (%), Throttles, Async delivery failures, IteratorAge, and Concurrent executions.
With AWS Lambda, you pay for what you use. After you hit your AWS Lambda free tier limit, you are charged based on the number of requests for your functions (invocation count) and the time your code executes (invocation duration).

![SS4](https://user-images.githubusercontent.com/26021273/206849510-e4295145-34bd-4f73-9ee4-cfaced0c1b76.png)
[ Figure: AWS Lambda Service usage ]

### AWS API Gateway Service

API Gateway handles all the tasks involved in accepting and processing up to hundreds of thousands of concurrent API calls, including traffic management, CORS support, authorization and access control, throttling, monitoring, and API version management. API Gateway has no minimum fees or startup costs. You pay for the API calls you receive and the amount of data transferred out and, with the API Gateway tiered pricing model, you can reduce your cost as your API usage scales.

Here, CloudFormation template has created `aws-blog-demo` API which contains getBlogs, getBlog, postBlog, and deleteBlog API methods. I have deployed in stage and prod environments. The call monitoring has been connected with AWS CloudWatch so that all monitoring can be tracked and alarms can be set up on AWS CLoudwatch.

![SS5](https://user-images.githubusercontent.com/26021273/206849512-86f032ed-3cff-4bae-bdce-00d41b7873b7.png)
[ Figure: AWS API Gateway Dashboard ]

### AWS CloudFormation

AWS CloudFormation is a service that helps you model and set up your AWS resources so that you can spend less time managing those resources and more time focusing on your applications that run in AWS. You create a template that describes all the AWS resources that you want (like Amazon EC2 instances or Amazon RDS DB instances), and CloudFormation takes care of provisioning and configuring those resources for you. You don't need to individually create and configure AWS resources and figure out what's dependent on what; CloudFormation handles that. 

Here, We have created aws-blog-demo stack in CloudFormation with the help of `tamplate.yaml` and SAM CLI. The template defines the resources mentioned below.

| Resource Name  | Type  |
|--|--|
| BlogTable | AWS::DynamoDB::Table |
| ServerlessRestApi | AWS::Lambda::Function |
| ServerlessRestApiDeployment | AWS::ApiGateway::Deployment |
| FargateCluster | AWS::ECS::Cluster |
| FargateService | AWS::ECS::Service |
| FargateLoadBalancer | AWS::ElasticLoadBalancingV2::LoadBalancer |
| FargateLoadBalancerListener | AWS::ElasticLoadBalancingV2::Listener |
| FargateSubnet1 | AWS::EC2::Subnet |
| FargateSubnet2 | AWS::EC2::Subnet |



![SS6](https://user-images.githubusercontent.com/26021273/206849513-a517d201-d10a-4c74-be26-8030983bd882.png)
[ Figure: AWS CloudFormation Resources ]

![SS7](https://user-images.githubusercontent.com/26021273/206849516-eb876616-d90d-4f36-a994-6b6c9423f600.png)
[ Figure: AWS DynamoDB Usage ]

![SS8](https://user-images.githubusercontent.com/26021273/206849517-8bed4a45-8bcf-4cf2-b017-11102d269be1.png)
[ Figure: AWS DynamoDB data items ]


![SS9](https://user-images.githubusercontent.com/26021273/206849519-7433f577-f15b-4f7a-92e4-5bfe86a86646.png)
[ Figure: AWS Cloudwatch Usage ]


![SS10](https://user-images.githubusercontent.com/26021273/206849521-b20ad6e3-e6e0-42f9-af88-5bee4031fe9a.png)
[ Figure: AWS Elastic Load Balancer Usage ]


### Comparison

Difference between serverless function and serverless container:
- Most of the time, serverless functions are compact, independent pieces of code that perform a single task. They often only last a few minutes, or if they are customer-facing a few seconds. 
- While containers are most effective for larger, longer-running, or applications with several functions.
- Running serverless outside of a public cloud environment is more challenging. There are local serverless frameworks, however, they are still complex and not widely adopted.
- Containers can be simply run on a developer's workstation or in a nearby data center.
- Although containers are by default stateless, stateful applications can be supported via persistent storage.
- Stateless workloads are supported by the majority of serverless runtimes. Stateful services are only partially supported by some serverless providers.
- Public cloud infrastructure houses serverless environments, which are invoiced on a usage basis.
- Most container orchestrators and engines are open sources, and you can use them to run locally for no cost (considering the time needed to deploy and maintain them).


### Conclusion

