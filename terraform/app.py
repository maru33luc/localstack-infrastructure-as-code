import json
import boto3
import os

def handler(event, context):
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