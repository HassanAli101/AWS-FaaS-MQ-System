# Doc: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function
resource "aws_lambda_function" "request_receiver" {
  filename      = "request-receiver-lambda.zip"
  function_name = "request-receiver-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "request-receiver-lambda.handler"
  runtime       = "python3.9" 
  timeout       = 10
  environment {
    variables = {
      RAW_DATA_BUCKET = aws_s3_bucket.raw_data_bucket.id
      ANALYTICS_QUEUE_URL = aws_sqs_queue.analytics_queue.url
    }
  }
  tags = {
    Purpose     = "Lab 2 Demonstration"
  }
}

resource "aws_lambda_function" "analytics_calculator" {
  filename      = "analytics-calculator-lambda.zip"
  function_name = "analytics-calculator-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "analytics-calculator-lambda.handler"
  runtime       = "python3.9" 
  timeout       = 10
  environment {
    variables = {
      RAW_DATA_BUCKET = aws_s3_bucket.raw_data_bucket.id
      PROCESSED_DATA_BUCKET = aws_s3_bucket.processed_data_bucket.id
      NOTIFICATION_QUEUE_URL = aws_sqs_queue.notification_queue.url
    }
  }
  tags = {
    Purpose     = "Lab 2 Demonstration"
  }
}

resource "aws_lambda_function" "result_notifier" {
  filename      = "result-notifier-lambda.zip"
  function_name = "result-notifier-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "result-notifier-lambda.handler"
  runtime       = "python3.9" 
  timeout       = 10
  environment {
    variables = {
      PROCESSED_DATA_BUCKET = aws_s3_bucket.processed_data_bucket.id
      SNS_TOPIC_ARN = aws_sns_topic.quiz_notification.arn
    }
  }
  tags = {
    Purpose     = "Lab 2 Demonstration"
  }
}

# Doc link: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping
resource "aws_lambda_event_source_mapping" "analytics_queue_mapping" {
  event_source_arn = aws_sqs_queue.analytics_queue.arn
  function_name    = aws_lambda_function.analytics_calculator.function_name
  batch_size       = 1
}

resource "aws_lambda_event_source_mapping" "notification_queue_mapping" {
  event_source_arn = aws_sqs_queue.notification_queue.arn
  function_name    = aws_lambda_function.result_notifier.function_name
  batch_size       = 1
}