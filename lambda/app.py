import json
import boto3
import os

s3 = boto3.client(
    's3',
    endpoint_url='http://localhost:4566',
    aws_access_key_id='test',
    aws_secret_access_key='test',
    region_name='us-east-1'
)

BUCKET = os.environ['BUCKET_NAME']

def handler(event, context):
    body = event.get('body', 'hola localstack')

    s3.put_object(
        Bucket=BUCKET,
        Key='example.txt',
        Body=body
    )

    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Archivo guardado en S3'})
    }