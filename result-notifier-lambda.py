import json
import boto3
import os
s3_client = boto3.client('s3')
sns_client = boto3.client('sns')
def handler(event, context):
    try:
        print(f'Received event: {json.dumps(event)}')
        sqs_message = json.loads(event['Records'][0]['body'])
        filename = sqs_message['filename']
        original_filename = sqs_message.get('originalFilename', 'unknown')
        print(f'Sending notification for file: {filename}')
        s3_response = s3_client.get_object(
            Bucket=os.environ['PROCESSED_DATA_BUCKET'],
            Key=filename
        )
        csv_content = s3_response['Body'].read().decode('utf-8')
        rows = csv_content.split('\n')
        headers = rows[0].split(',')
        email_content = 'Quiz Statistics Report\n\n'
        for i in range(1, len(rows)):
            columns = rows[i].split(',')
            if len(columns) >= 4:
                email_content += f'Quiz: {columns[0]}\n'
                email_content += f'Minimum Score: {columns[1]}\n'
                email_content += f'Maximum Score: {columns[2]}\n'
                email_content += f'Mean Score: {columns[3]}\n\n'
        sns_client.publish(
            TopicArn=os.environ['SNS_TOPIC_ARN'],
            Subject='Quiz Statistics Report',
            Message=email_content
        )
        print('Email notification sent')
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Quiz statistics report sent',
                'resultsFilename': filename
            })
        }
    except Exception as e:
        print(f'Error: {str(e)}')
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Error sending notification', 'error': str(e)})
        }
