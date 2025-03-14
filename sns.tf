# Doc: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic
resource "aws_sns_topic" "quiz_notification" {
  name = "CS487-Spring2025-Lab2-Quiz-Statistics-Notification"
  tags = {
    Purpose     = "Lab 2 Demonstration"
  }
}

# Doc: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription
resource "aws_sns_topic_subscription" "email_subscriptions" {
  topic_arn = aws_sns_topic.quiz_notification.arn
  protocol  = "email"
  endpoint  = var.subscriber_email
}