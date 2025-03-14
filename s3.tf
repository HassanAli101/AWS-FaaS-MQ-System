# Doc Link: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "raw_data_bucket" {
	bucket = "CS487-Spring2025-Lab2-Raw-Quiz-Scores-Bucket"
	force_destroy = true
	tags = {
    Purpose     = "Lab 2 Demonstration"
  }
}

resource "aws_s3_bucket" "processed_data_bucket" {
	bucket = "CS487-Spring2025-Lab2-Processed-Quiz-Scores-Bucket"
	force_destroy = true
	tags = {
    Purpose     = "Lab 2 Demonstration"
  }
}