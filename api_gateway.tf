# Doc: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api
resource "aws_api_gateway_rest_api" "quiz_api" {
  name        = "quiz-statistics-api"
  description = "API for submitting quiz data"
  binary_media_types = ["application/json", "multipart/form-data"]
  tags = {
    Purpose     = "Lab 2 Demonstration"
  }
}

# Doc: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/api_gateway_resource
resource "aws_api_gateway_resource" "quiz_resource" {
  rest_api_id = aws_api_gateway_rest_api.quiz_api.id
  parent_id   = aws_api_gateway_rest_api.quiz_api.root_resource_id
  path_part   = "submit-quiz"
}

# Doc: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method
resource "aws_api_gateway_method" "quiz_method" {
  rest_api_id   = aws_api_gateway_rest_api.quiz_api.id
  resource_id   = aws_api_gateway_resource.quiz_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Doc: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.quiz_api.id
  resource_id             = aws_api_gateway_resource.quiz_resource.id
  http_method             = aws_api_gateway_method.quiz_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.request_receiver.invoke_arn
}

# For the preflight request sent by browsers.
resource "aws_api_gateway_method" "options_method" {
  rest_api_id   = aws_api_gateway_rest_api.quiz_api.id
  resource_id   = aws_api_gateway_resource.quiz_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id = aws_api_gateway_rest_api.quiz_api.id
  resource_id = aws_api_gateway_resource.quiz_resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  type        = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Doc: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response
resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.quiz_api.id
  resource_id = aws_api_gateway_resource.quiz_resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# Doc: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response
resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.quiz_api.id
  resource_id = aws_api_gateway_resource.quiz_resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = aws_api_gateway_method_response.options_200.status_code
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

resource "aws_lambda_permission" "api_gateway_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.request_receiver.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.quiz_api.execution_arn}/*/${aws_api_gateway_method.quiz_method.http_method}${aws_api_gateway_resource.quiz_resource.path}"
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.quiz_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.quiz_api.id
  stage_name    = "prod"
}

resource "aws_api_gateway_deployment" "quiz_api_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_integration.options_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.quiz_api.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.quiz_resource.id,
      aws_api_gateway_method.quiz_method.id,
      aws_api_gateway_integration.lambda_integration.id,
      aws_api_gateway_method.options_method.id,
      aws_api_gateway_integration.options_integration.id,
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}

