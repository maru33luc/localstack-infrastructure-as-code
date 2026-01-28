#!/bin/bash

# Crear bucket S3
aws --endpoint-url=http://localhost:4566 s3 mb s3://my-local-bucket

# Crear rol IAM
aws --endpoint-url=http://localhost:4566 iam create-role \
  --role-name lambda-execution-role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {"Service": "lambda.amazonaws.com"},
        "Action": "sts:AssumeRole"
      }
    ]
  }'

# Adjuntar políticas al rol
aws --endpoint-url=http://localhost:4566 iam attach-role-policy \
  --role-name lambda-execution-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

aws --endpoint-url=http://localhost:4566 iam attach-role-policy \
  --role-name lambda-execution-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

# Crear función Lambda
zip lambda-code.zip lambda/app.py
aws --endpoint-url=http://localhost:4566 lambda create-function \
  --function-name my-local-lambda \
  --runtime python3.9 \
  --role arn:aws:iam::000000000000:role/lambda-execution-role \
  --handler app.handler \
  --zip-file fileb://lambda-code.zip \
  --environment Variables='{BUCKET_NAME=my-local-bucket}'

# Crear API Gateway
API_ID=$(aws --endpoint-url=http://localhost:4566 apigateway create-rest-api \
  --name LocalApi --query 'id' --output text)

# Obtener root resource ID
ROOT_ID=$(aws --endpoint-url=http://localhost:4566 apigateway get-resources \
  --rest-api-id $API_ID --query 'items[0].id' --output text)

# Crear recurso /test
RESOURCE_ID=$(aws --endpoint-url=http://localhost:4566 apigateway create-resource \
  --rest-api-id $API_ID \
  --parent-id $ROOT_ID \
  --path-part test --query 'id' --output text)

# Crear método POST
aws --endpoint-url=http://localhost:4566 apigateway put-method \
  --rest-api-id $API_ID \
  --resource-id $RESOURCE_ID \
  --http-method POST \
  --authorization-type NONE

# Integrar con Lambda
aws --endpoint-url=http://localhost:4566 apigateway put-integration \
  --rest-api-id $API_ID \
  --resource-id $RESOURCE_ID \
  --http-method POST \
  --type AWS_PROXY \
  --integration-http-method POST \
  --uri arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:my-local-lambda/invocations

# Dar permisos a API Gateway
aws --endpoint-url=http://localhost:4566 lambda add-permission \
  --function-name my-local-lambda \
  --statement-id api-gateway-invoke \
  --action lambda:InvokeFunction \
  --principal apigateway.amazonaws.com

# Desplegar API
aws --endpoint-url=http://localhost:4566 apigateway create-deployment \
  --rest-api-id $API_ID \
  --stage-name dev

echo "API ID: $API_ID"
echo "Test URL: http://localhost:4566/restapis/$API_ID/dev/_user_request_/test"