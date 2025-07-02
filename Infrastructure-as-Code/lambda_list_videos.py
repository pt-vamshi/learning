import os
import boto3
import json

def handler(event, context):
    s3 = boto3.client('s3')
    bucket = os.environ['S3_BUCKET']
    cloudfront_url = os.environ.get('CLOUDFRONT_URL', '')
    prefix = 'videos/'
    response = s3.list_objects_v2(Bucket=bucket, Prefix=prefix)
    videos = []
    for obj in response.get('Contents', []):
        key = obj['Key']
        if key.endswith('.mp4') or key.endswith('.webm') or key.endswith('.mov'):
            videos.append(f"{cloudfront_url}/{key}")
    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
        'body': json.dumps({'videos': videos})
    } 