import json
import boto3
import os
import datetime
s3_client = boto3.client('s3')
sqs_client = boto3.client('sqs')
def handler(event, context):
    try:
        print(f'Received event: {json.dumps(event)}')
        body = json.loads(event['body'])
        if not body.get('data') or not isinstance(body['data'], list):
            return {
                'statusCode': 400,
                'body': json.dumps({'message': 'Invalid request format. Expected "data" array.'})
            }
        csv_content = '\n'.join(body['data'])
        timestamp = datetime.datetime.now().isoformat().replace(':', '-').replace('.', '-')
        filename = f'quiz_data_{timestamp}.csv'
        s3_client.put_object(
            Bucket=os.environ['RAW_DATA_BUCKET'],
            Key=filename,
            Body=csv_content,
            ContentType='text/csv'
        )
        print(f'File uploaded to S3: {filename}')
        sqs_client.send_message(
            QueueUrl=os.environ['ANALYTICS_QUEUE_URL'],
            MessageBody=json.dumps({
                'filename': filename,
                'timestamp': timestamp
            })
        )
        print('Message sent to analytics queue')
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Quiz data received and processing started',
                'filename': filename
            })
        }
    except Exception as e:
        print(f'Error: {str(e)}')
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Internal server error', 'error': str(e)})
        }
