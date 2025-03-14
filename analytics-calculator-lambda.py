import json
import boto3
import os
import statistics
s3_client = boto3.client('s3')
sqs_client = boto3.client('sqs')
def handler(event, context):
    try:
        print(f'Received event: {json.dumps(event)}')
        sqs_message = json.loads(event['Records'][0]['body'])
        filename = sqs_message['filename']
        print(f'Processing file: {filename}')
        s3_response = s3_client.get_object(
            Bucket=os.environ['RAW_DATA_BUCKET'],
            Key=filename
        )
        csv_content = s3_response['Body'].read().decode('utf-8')
        rows = csv_content.split('\n')
        quiz_stats = []
        for row in rows:
            columns = row.split(',')
            quiz_name = columns[0]
            scores = [float(score) for score in columns[1:]]
            min_score = min(scores)
            max_score = max(scores)
            mean_score = round(sum(scores) / len(scores), 2)
            quiz_stats.append({
                'quiz': quiz_name,
                'min': min_score,
                'max': max_score,
                'mean': mean_score
            })
        stats_rows = [f"{stat['quiz']},{stat['min']},{stat['max']},{stat['mean']}" for stat in quiz_stats]
        stats_content = 'Quiz,Min Score,Max Score,Mean Score\n' + '\n'.join(stats_rows)
        results_filename = filename.replace('quiz_data', 'quiz_stats')
        s3_client.put_object(
            Bucket=os.environ['PROCESSED_DATA_BUCKET'],
            Key=results_filename,
            Body=stats_content,
            ContentType='text/csv'
        )
        print(f'Statistics uploaded to S3: {results_filename}')
        sqs_client.send_message(
            QueueUrl=os.environ['NOTIFICATION_QUEUE_URL'],
            MessageBody=json.dumps({
                'filename': results_filename,
                'originalFilename': filename,
                'timestamp': datetime.datetime.now().isoformat()
            })
        )
        print('Message sent to notification queue')
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Quiz statistics calculated and stored',
                'resultsFilename': results_filename
            })
        }
    except Exception as e:
        print(f'Error: {str(e)}')
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Error processing quiz data', 'error': str(e)})
        }
