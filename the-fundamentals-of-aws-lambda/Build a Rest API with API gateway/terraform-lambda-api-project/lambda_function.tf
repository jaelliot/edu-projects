resource "aws_lambda_function" "my_lambda" {
  function_name = var.lambda_function_name
  handler       = "index.handler" # Adjust based on your handler
  runtime       = var.lambda_runtime
  role          = aws_iam_role.lambda_exec_role.arn
  filename      = "path/to/your/lambda.zip" # Path to your Lambda deployment package

  # Define environment variables, if any
  environment {
    variables = {
      key = "value"
    }
  }
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
    }],
  })
}
