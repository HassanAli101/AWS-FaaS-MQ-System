# Doc link: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue
resource "aws_sqs_queue" "analytics_queue" {
  name = "CS487-Spring2025-Lab2-Quiz-Analytics-Queue"
  message_retention_seconds = 86400
   tags = {
    Purpose     = "Lab 2 Demonstration"
  }
}

resource "aws_sqs_queue" "notification_queue" {
  name = "CS487-Spring2025-Lab2-Quiz-Notification-Queue"
  message_retention_seconds = 86400
  tags = {
    Purpose     = "Lab 2 Demonstration"
  }
}