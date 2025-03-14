#Doc: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "request_receiver_logs" {
  name              = "/aws/lambda/${aws_lambda_function.request_receiver.function_name}"
  retention_in_days = 30
  tags = {
    Purpose     = "Lab 2 Demonstration"
  }
}

resource "aws_cloudwatch_log_group" "analytics_calculator_logs" {
  name              = "/aws/lambda/${aws_lambda_function.analytics_calculator.function_name}"
  retention_in_days = 30
  tags = {
    Purpose     = "Lab 2 Demonstration"
  }
}

resource "aws_cloudwatch_log_group" "result_notifier_logs" {
  name              = "/aws/lambda/${aws_lambda_function.result_notifier.function_name}"
  retention_in_days = 30
  tags = {
    Purpose     = "Lab 2 Demonstration"
  }
}
