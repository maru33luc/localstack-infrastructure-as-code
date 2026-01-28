# AWS LocalStack - CloudFormation vs Terraform

This project demonstrates how to create the same serverless infrastructure using **CloudFormation** and **Terraform** with **LocalStack** for local development.

## 📋 Architecture

```
Client → API Gateway → Lambda Function → S3 Bucket
  POST      /test        Python Code     Storage
```

**Components:**
- **API Gateway**: REST endpoint `/test` (POST)
- **Lambda Function**: Processes requests and saves data
- **S3 Bucket**: Stores files
- **IAM Role**: Permissions for Lambda

## 🛠️ Prerequisites

Before running this project, make sure you have the following tools installed:

### Required Tools

#### 1. Docker & Docker Compose
**Purpose**: Run LocalStack container

**Windows:**
```bash
# Install Docker Desktop
# Download from: https://www.docker.com/products/docker-desktop/

# Verify installation
docker --version
docker-compose --version
```

**macOS:**
```bash
# Install Docker Desktop
brew install --cask docker

# Or download from: https://www.docker.com/products/docker-desktop/
```

**Linux:**
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io docker-compose

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker
```

#### 2. AWS CLI
**Purpose**: Interact with LocalStack services

**Windows:**
```bash
# Using winget
winget install Amazon.AWSCLI

# Or download MSI from: https://aws.amazon.com/cli/
```

**macOS:**
```bash
# Using Homebrew
brew install awscli

# Or using pip
pip3 install awscli
```

**Linux:**
```bash
# Using pip
pip3 install awscli

# Or using package manager (Ubuntu/Debian)
sudo apt install awscli
```

**Verify installation:**
```bash
aws --version
```

#### 3. Terraform (Optional - for Terraform method)
**Purpose**: Deploy infrastructure using Terraform

**Windows:**
```bash
# Using winget
winget install HashiCorp.Terraform

# Using Chocolatey
choco install terraform

# Or download from: https://terraform.io/downloads
```

**macOS:**
```bash
# Using Homebrew
brew install terraform
```

**Linux:**
```bash
# Ubuntu/Debian
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

**Verify installation:**
```bash
terraform --version
```

#### 4. PowerShell (Windows) or curl (Linux/macOS)
**Purpose**: Test API endpoints

**Windows:** PowerShell is pre-installed

**Linux/macOS:**
```bash
# curl is usually pre-installed, if not:
# Ubuntu/Debian
sudo apt install curl

# macOS
brew install curl
```

### Optional Tools

#### Git
**Purpose**: Clone repository and version control
```bash
# Windows
winget install Git.Git

# macOS
brew install git

# Linux
sudo apt install git
```

#### Python 3.9+ (for local development)
**Purpose**: Modify Lambda functions locally
```bash
# Windows
winget install Python.Python.3.9

# macOS
brew install python@3.9

# Linux
sudo apt install python3.9 python3-pip
```

### Verification Script

Run this script to verify all tools are installed correctly:

```bash
#!/bin/bash
echo "Checking prerequisites..."

# Check Docker
if command -v docker &> /dev/null; then
    echo "✅ Docker: $(docker --version)"
else
    echo "❌ Docker: Not installed"
fi

# Check Docker Compose
if command -v docker-compose &> /dev/null; then
    echo "✅ Docker Compose: $(docker-compose --version)"
else
    echo "❌ Docker Compose: Not installed"
fi

# Check AWS CLI
if command -v aws &> /dev/null; then
    echo "✅ AWS CLI: $(aws --version)"
else
    echo "❌ AWS CLI: Not installed"
fi

# Check Terraform (optional)
if command -v terraform &> /dev/null; then
    echo "✅ Terraform: $(terraform --version | head -n1)"
else
    echo "⚠️  Terraform: Not installed (optional for Terraform method)"
fi

echo "\nPrerequisites check completed!"
```

## 🚀 Quick Start

### 1. Clone the repository:
```bash
git clone https://github.com/maru33luc/localstack-infrastructure-as-code.git
cd localstack-infrastructure-as-code
```

### 2. Start LocalStack:
```bash
docker-compose up -d
```

### 3. Verify LocalStack is running:
```bash
curl http://localhost:4566/_localstack/health
```

### 4. Choose your deployment method:
- **CloudFormation**: Follow [Method 1](#method-1-cloudformation) - Ready to use!
- **Terraform**: Follow [Method 2](#method-2-terraform) - Requires initialization

## ⚠️ Important Notes

### Files Not Included in Repository
The following files are automatically generated and excluded from Git:

**Terraform:**
- `.terraform/` - Downloaded when you run `terraform init`
- `terraform.tfstate` - Created when you run `terraform apply`
- `lambda-code.zip` - Created when you run the ZIP command

**LocalStack:**
- `tmp/` - Created by LocalStack for temporary data

**Why excluded?** These files are:
- ✅ **Large** (providers can be 500MB+)
- ✅ **Machine-specific** (contain local paths)
- ✅ **Auto-generated** (recreated on each setup)
- ✅ **Temporary** (not needed for version control)

### How to Generate Missing Files

**For Terraform method:**
```bash
# 1. Initialize Terraform (downloads providers to .terraform/)
cd terraform
terraform init

# 2. Create Lambda ZIP file
powershell Compress-Archive -Path app.py -DestinationPath lambda-code.zip

# 3. Now you can run terraform plan/apply
terraform plan
```

**For CloudFormation method:**
```bash
# No additional setup needed - code is embedded in the template!
aws --endpoint-url=http://localhost:4566 cloudformation create-stack ...
```

## 🏗️ Project Structure

```
aws-localstack/
├── docker-compose.yml          # LocalStack configuration
├── infra/
│   └── stack.yaml             # CloudFormation template
├── lambda/
│   └── app.py                 # Lambda source code
├── terraform/
│   ├── provider.tf            # Terraform AWS provider config
│   ├── main.tf                # Terraform resources
│   └── app.py                 # Lambda code for Terraform
└── README.md                  # This file
```

## 🐳 LocalStack Setup

### 1. Docker Compose

```yaml
version: '3.8'

services:
  localstack:
    container_name: localstack_main
    image: localstack/localstack:latest
    ports:
      - "4566:4566"
    environment:
      - SERVICES=cloudformation,lambda,s3,apigateway,iam,logs
      - DEBUG=1
      - LAMBDA_EXECUTOR=docker
      - DOCKER_HOST=unix:///var/run/docker.sock
      - LOCALSTACK_HOST=localhost
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
      - "./tmp/localstack:/var/lib/localstack"
    networks:
      - localstack-net

networks:
  localstack-net:
    driver: bridge
```

### 2. Start LocalStack

```bash
docker-compose up -d
```

### 3. Verify services

```bash
curl http://localhost:4566/_localstack/health
```

## ☁️ Method 1: CloudFormation

### File: `infra/stack.yaml`

```yaml
%YAML 1.1
---
AWSTemplateFormatVersion: '2010-09-09'
Description: 'LocalStack Lambda with S3 and API Gateway'

Resources:
  MyBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: my-local-bucket

  MyLambda:
    Type: AWS::Lambda::Function
    Properties:
      FunctionName: my-local-lambda
      Runtime: python3.9
      Handler: app.handler
      Role: !GetAtt 'LambdaRole.Arn'
      Code:
        ZipFile: |
          import json
          import boto3
          import os
          
          def handler(event, context):
              try:
                  s3 = boto3.client('s3')
                  
                  BUCKET = os.environ['BUCKET_NAME']
                  body = event.get('body', 'hello localstack')
              
                  s3.put_object(
                      Bucket=BUCKET,
                      Key='example.txt',
                      Body=body
                  )
              
                  return {
                      'statusCode': 200,
                      'body': json.dumps({'message': 'File saved to S3'})
                  }
              except Exception as e:
                  return {
                      'statusCode': 500,
                      'body': json.dumps({'error': str(e)})
                  }
      Environment:
        Variables:
          BUCKET_NAME: my-local-bucket

  LambdaRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: lambda-execution-role
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: lambda.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
        - arn:aws:iam::aws:policy/AmazonS3FullAccess

  Api:
    Type: AWS::ApiGateway::RestApi
    Properties:
      Name: LocalApi

  ApiResource:
    Type: AWS::ApiGateway::Resource
    Properties:
      ParentId: !GetAtt 'Api.RootResourceId'
      PathPart: test
      RestApiId: !Ref 'Api'

  ApiMethod:
    Type: AWS::ApiGateway::Method
    Properties:
      HttpMethod: POST
      ResourceId: !Ref 'ApiResource'
      RestApiId: !Ref 'Api'
      AuthorizationType: NONE
      Integration:
        Type: AWS_PROXY
        IntegrationHttpMethod: POST
        Uri: !Sub 'arn:aws:apigateway:${AWS::Region}:lambda:path/2015-03-31/functions/${MyLambda.Arn}/invocations'

  LambdaPermission:
    Type: AWS::Lambda::Permission
    Properties:
      FunctionName: !Ref 'MyLambda'
      Action: lambda:InvokeFunction
      Principal: apigateway.amazonaws.com
      SourceArn: !Sub 'arn:aws:apigateway:${AWS::Region}::/restapis/${Api}/stages/*/POST/test'

  ApiDeployment:
    Type: AWS::ApiGateway::Deployment
    DependsOn: ApiMethod
    Properties:
      RestApiId: !Ref 'Api'
      StageName: dev
```

### CloudFormation Steps

1. **Deploy the stack:**
```bash
aws --endpoint-url=http://localhost:4566 cloudformation create-stack \
  --stack-name my-local-stack \
  --template-body file://infra/stack.yaml \
  --capabilities CAPABILITY_NAMED_IAM
```

2. **Verify deployment:**
```bash
aws --endpoint-url=http://localhost:4566 cloudformation describe-stacks \
  --stack-name my-local-stack
```

3. **Get API ID:**
```bash
aws --endpoint-url=http://localhost:4566 apigateway get-rest-apis
```

4. **Test API:**
```powershell
Invoke-RestMethod -Uri "http://localhost:4566/restapis/{api-id}/dev/_user_request_/test" -Method POST -ContentType "application/json" -Body '{"message": "Hello CloudFormation!"}'
```

5. **Verify S3:**
```bash
aws --endpoint-url=http://localhost:4566 s3 ls s3://my-local-bucket/
aws --endpoint-url=http://localhost:4566 s3 cp s3://my-local-bucket/example.txt -
```

## 🏗️ Method 2: Terraform

### File: `terraform/provider.tf`

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style          = true

  endpoints {
    s3             = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    apigateway     = "http://localhost:4566"
    iam            = "http://localhost:4566"
  }
}
```

### File: `terraform/main.tf`

```hcl
# S3 Bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-local-bucket-tf"
}

# IAM Role
resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role-tf"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# IAM Policies
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Lambda Function
resource "aws_lambda_function" "my_lambda_tf" {
  filename         = "lambda-code.zip"
  function_name    = "my-local-lambda-tf"
  role            = aws_iam_role.lambda_role.arn
  handler         = "app.handler"
  runtime         = "python3.9"
  
  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.my_bucket.bucket
    }
  }
}

# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = "LocalApi-tf"
}

resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "test"
}

resource "aws_api_gateway_method" "api_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.api_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.api_resource.id
  http_method = aws_api_gateway_method.api_method.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.my_lambda_tf.invoke_arn
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda_tf.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_method.api_method,
    aws_api_gateway_integration.lambda_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "dev"
}
```

### File: `terraform/app.py`

```python
import json
import boto3
import os

def handler(event, context):
    try:
        s3 = boto3.client('s3')
        
        BUCKET = os.environ['BUCKET_NAME']
        body = event.get('body', 'hello terraform')
    
        s3.put_object(
            Bucket=BUCKET,
            Key='terraform-example.txt',
            Body=body
        )
    
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'File saved with Terraform'})
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
```

### Terraform Steps

1. **Initialize Terraform:**
```bash
cd terraform
terraform init
```

2. **Create Lambda ZIP:**
```bash
powershell Compress-Archive -Path app.py -DestinationPath lambda-code.zip
```

3. **View execution plan:**
```bash
terraform plan
```

4. **Apply changes:**
```bash
terraform apply
# Type 'yes' when prompted
```

5. **Get API ID:**
```bash
aws --endpoint-url=http://localhost:4566 apigateway get-rest-apis --query 'items[?name==`LocalApi-tf`].id' --output text
```

6. **Test API:**
```powershell
Invoke-RestMethod -Uri "http://localhost:4566/restapis/{api-id}/dev/_user_request_/test" -Method POST -ContentType "application/json" -Body '{"message": "Hello Terraform!"}'
```

7. **Verify S3:**
```bash
aws --endpoint-url=http://localhost:4566 s3 ls s3://my-local-bucket-tf/
aws --endpoint-url=http://localhost:4566 s3 cp s3://my-local-bucket-tf/terraform-example.txt -
```

## 🔧 Useful Commands

### Verify created resources

```bash
# List S3 buckets
aws --endpoint-url=http://localhost:4566 s3 ls

# List Lambda functions
aws --endpoint-url=http://localhost:4566 lambda list-functions

# List APIs
aws --endpoint-url=http://localhost:4566 apigateway get-rest-apis

# View LocalStack logs
docker-compose logs -f localstack
```

### Clean up resources

```bash
# CloudFormation
aws --endpoint-url=http://localhost:4566 cloudformation delete-stack --stack-name my-local-stack

# Terraform
cd terraform
terraform destroy
```

## 📊 CloudFormation vs Terraform Comparison

| **Aspect** | **CloudFormation** | **Terraform** |
|------------|-------------------|---------------|
| **Syntax** | YAML/JSON | HCL |
| **Providers** | AWS only | Multi-cloud |
| **State** | AWS managed | Local file |
| **Preview** | Limited | `terraform plan` |
| **Modularity** | Limited | Excellent |
| **Learning curve** | Easy for AWS | Moderate |
| **Ecosystem** | AWS native | Broad |

## 🚀 Results

Both methods create the same infrastructure:

- **CloudFormation**: 
  - API: `LocalApi`
  - Lambda: `my-local-lambda`
  - Bucket: `my-local-bucket`
  - File: `example.txt`

- **Terraform**:
  - API: `LocalApi-tf`
  - Lambda: `my-local-lambda-tf`
  - Bucket: `my-local-bucket-tf`
  - File: `terraform-example.txt`

## 🐛 Troubleshooting

### Error: Service not enabled
```bash
# Verify LocalStack has all services
curl http://localhost:4566/_localstack/health
```

### Error: S3 bucket creation failed
```bash
# Add s3_use_path_style = true in provider.tf
```

### Error: Lambda timeout
```bash
# View LocalStack logs
docker-compose logs -f localstack
```

### Error: API Gateway 502
```bash
# Verify Lambda integration
aws --endpoint-url=http://localhost:4566 apigateway get-integration \
  --rest-api-id {api-id} --resource-id {resource-id} --http-method POST
```

## 📚 Additional Resources

- [LocalStack Documentation](https://docs.localstack.cloud/)
- [AWS CloudFormation User Guide](https://docs.aws.amazon.com/cloudformation/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS CLI Reference](https://docs.aws.amazon.com/cli/)

---

**Project completed successfully!** 🎉

Both implementations (CloudFormation and Terraform) create the same serverless infrastructure running on LocalStack for local development.p s3://my-local-bucket/example.txt -
```

## 🏗️ Method 2: Terraform

### File: `terraform/provider.tf`

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style          = true

  endpoints {
    s3             = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    apigateway     = "http://localhost:4566"
    iam            = "http://localhost:4566"
  }
}
```

### File: `terraform/main.tf`

```hcl
# S3 Bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-local-bucket-tf"
}

# IAM Role
resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role-tf"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# IAM Policies
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Lambda Function
resource "aws_lambda_function" "my_lambda_tf" {
  filename         = "lambda-code.zip"
  function_name    = "my-local-lambda-tf"
  role            = aws_iam_role.lambda_role.arn
  handler         = "app.handler"
  runtime         = "python3.9"
  
  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.my_bucket.bucket
    }
  }
}

# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = "LocalApi-tf"
}

resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "test"
}

resource "aws_api_gateway_method" "api_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.api_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.api_resource.id
  http_method = aws_api_gateway_method.api_method.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.my_lambda_tf.invoke_arn
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda_tf.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_method.api_method,
    aws_api_gateway_integration.lambda_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "dev"
}
```

### File: `terraform/app.py`

```python
import json
import boto3
import os

def handler(event, context):
    try:
        s3 = boto3.client('s3')
        
        BUCKET = os.environ['BUCKET_NAME']
        body = event.get('body', 'hello terraform')
    
        s3.put_object(
            Bucket=BUCKET,
            Key='terraform-example.txt',
            Body=body
        )
    
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'File saved with Terraform'})
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
```

### Terraform Steps

**Prerequisites:** Make sure you have completed the [setup steps](#important-notes) above.

1. **Initialize Terraform (downloads providers):**
```bash
cd terraform
terraform init
```

2. **Create Lambda ZIP:**
```bash
powershell Compress-Archive -Path app.py -DestinationPath lambda-code.zip
```

3. **View execution plan:**
```bash
terraform plan
```

4. **Apply changes:**
```bash
terraform apply
# Type 'yes' when prompted
```

6. **Get API ID:**
```bash
aws --endpoint-url=http://localhost:4566 apigateway get-rest-apis --query 'items[?name==`LocalApi-tf`].id' --output text
```

7. **Test API:**
```powershell
Invoke-RestMethod -Uri "http://localhost:4566/restapis/{api-id}/dev/_user_request_/test" -Method POST -ContentType "application/json" -Body '{"message": "Hello Terraform!"}'
```

8. **Verify S3:**
```bash
aws --endpoint-url=http://localhost:4566 s3 ls s3://my-local-bucket-tf/
aws --endpoint-url=http://localhost:4566 s3 cp s3://my-local-bucket-tf/terraform-example.txt -
```

## 🔧 Useful Commands

### Verify created resources

```bash
# List S3 buckets
aws --endpoint-url=http://localhost:4566 s3 ls

# List Lambda functions
aws --endpoint-url=http://localhost:4566 lambda list-functions

# List APIs
aws --endpoint-url=http://localhost:4566 apigateway get-rest-apis

# View LocalStack logs
docker-compose logs -f localstack
```

### Clean up resources

```bash
# CloudFormation
aws --endpoint-url=http://localhost:4566 cloudformation delete-stack --stack-name my-local-stack

# Terraform
cd terraform
terraform destroy
```

## 📊 CloudFormation vs Terraform Comparison

| **Aspect** | **CloudFormation** | **Terraform** |
|------------|-------------------|---------------|
| **Syntax** | YAML/JSON | HCL |
| **Providers** | AWS only | Multi-cloud |
| **State** | AWS managed | Local file |
| **Preview** | Limited | `terraform plan` |
| **Modularity** | Limited | Excellent |
| **Learning curve** | Easy for AWS | Moderate |
| **Ecosystem** | AWS native | Broad |

## 🚀 Results

Both methods create the same infrastructure:

- **CloudFormation**: 
  - API: `LocalApi`
  - Lambda: `my-local-lambda`
  - Bucket: `my-local-bucket`
  - File: `example.txt`

- **Terraform**:
  - API: `LocalApi-tf`
  - Lambda: `my-local-lambda-tf`
  - Bucket: `my-local-bucket-tf`
  - File: `terraform-example.txt`

## 🐛 Troubleshooting

### Error: Service not enabled
```bash
# Verify LocalStack has all services
curl http://localhost:4566/_localstack/health
```

### Error: S3 bucket creation failed
```bash
# Add s3_use_path_style = true in provider.tf
```

### Error: Lambda timeout
```bash
# View LocalStack logs
docker-compose logs -f localstack
```

### Error: API Gateway 502
```bash
# Verify Lambda integration
aws --endpoint-url=http://localhost:4566 apigateway get-integration \
  --rest-api-id {api-id} --resource-id {resource-id} --http-method POST
```

## 📚 Additional Resources

- [LocalStack Documentation](https://docs.localstack.cloud/)
- [AWS CloudFormation User Guide](https://docs.aws.amazon.com/cloudformation/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS CLI Reference](https://docs.aws.amazon.com/cli/)

---

**Project completed successfully!** 🎉

Both implementations (CloudFormation and Terraform) create the same serverless infrastructure running on LocalStack for local development.ntext):
    try:
        s3 = boto3.client('s3')
        
        BUCKET = os.environ['BUCKET_NAME']
        body = event.get('body', 'hola terraform')
    
        s3.put_object(
            Bucket=BUCKET,
            Key='terraform-example.txt',
            Body=body
        )
    
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Archivo guardado con Terraform'})
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
```

### Pasos Terraform

1. **Instalar Terraform:**
```bash
# Windows con winget
winget install HashiCorp.Terraform

# O descargar desde: https://terraform.io/downloads
```

2. **Crear ZIP de Lambda:**
```bash
cd terraform
powershell Compress-Archive -Path app.py -DestinationPath lambda-code.zip
```

3. **Inicializar Terraform:**
```bash
terraform init
```

4. **Ver plan de ejecución:**
```bash
terraform plan
```

5. **Aplicar cambios:**
```bash
terraform apply
# Escribir 'yes' cuando pregunte
```

6. **Obtener API ID:**
```bash
aws --endpoint-url=http://localhost:4566 apigateway get-rest-apis --query 'items[?name==`LocalApi-tf`].id' --output text
```

7. **Probar API:**
```powershell
Invoke-RestMethod -Uri "http://localhost:4566/restapis/{api-id}/dev/_user_request_/test" -Method POST -ContentType "application/json" -Body '{"message": "Hola Terraform!"}'
```

8. **Verificar S3:**
```bash
aws --endpoint-url=http://localhost:4566 s3 ls s3://my-local-bucket-tf/
aws --endpoint-url=http://localhost:4566 s3 cp s3://my-local-bucket-tf/terraform-example.txt -
```

## 🔧 Comandos Útiles

### Verificar recursos creados

```bash
# Ver buckets S3
aws --endpoint-url=http://localhost:4566 s3 ls

# Ver funciones Lambda
aws --endpoint-url=http://localhost:4566 lambda list-functions

# Ver APIs
aws --endpoint-url=http://localhost:4566 apigateway get-rest-apis

# Ver logs de LocalStack
docker-compose logs -f localstack
```

### Limpiar recursos

```bash
# CloudFormation
aws --endpoint-url=http://localhost:4566 cloudformation delete-stack --stack-name my-local-stack

# Terraform
cd terraform
terraform destroy
```

## 📊 Comparación CloudFormation vs Terraform

| **Aspecto** | **CloudFormation** | **Terraform** |
|-------------|-------------------|---------------|
| **Sintaxis** | YAML/JSON | HCL |
| **Proveedores** | Solo AWS | Multi-cloud |
| **Estado** | Administrado por AWS | Archivo local |
| **Preview** | Limited | `terraform plan` |
| **Modularidad** | Limitada | Excelente |
| **Curva de aprendizaje** | Fácil para AWS | Moderada |
| **Ecosistema** | AWS nativo | Amplio |

## 🚀 Resultados

Ambos métodos crean la misma infraestructura:

- **CloudFormation**: 
  - API: `LocalApi`
  - Lambda: `my-local-lambda`
  - Bucket: `my-local-bucket`
  - Archivo: `example.txt`

- **Terraform**:
  - API: `LocalApi-tf`
  - Lambda: `my-local-lambda-tf`
  - Bucket: `my-local-bucket-tf`
  - Archivo: `terraform-example.txt`

## 🐛 Troubleshooting

### Error: Service not enabled
```bash
# Verificar que LocalStack tenga todos los servicios
curl http://localhost:4566/_localstack/health
```

### Error: S3 bucket creation failed
```bash
# Agregar s3_use_path_style = true en provider.tf
```

### Error: Lambda timeout
```bash
# Ver logs de LocalStack
docker-compose logs -f localstack
```

### Error: API Gateway 502
```bash
# Verificar integración Lambda
aws --endpoint-url=http://localhost:4566 apigateway get-integration \
  --rest-api-id {api-id} --resource-id {resource-id} --http-method POST
```

## 📚 Recursos Adicionales

- [LocalStack Documentation](https://docs.localstack.cloud/)
- [AWS CloudFormation User Guide](https://docs.aws.amazon.com/cloudformation/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS CLI Reference](https://docs.aws.amazon.com/cli/)

---

**¡Proyecto completado exitosamente!** 🎉

Ambas implementaciones (CloudFormation y Terraform) crean la misma infraestructura serverless funcionando en LocalStack para desarrollo local.