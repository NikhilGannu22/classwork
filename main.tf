provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "lambda_trigger_bucket" {
  bucket = "my-lambda-trigger22-bucket"
}

# Create IAM Role for Lambda Function
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach necessary policies to the Lambda IAM Role
resource "aws_iam_policy_attachment" "lambda_exec_policy" {
  name       = "lambda_exec_policy"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "s3_lambda" {
  function_name = "S3TriggerLambda"
  role          = aws_iam_role.lambda_exec_role.arn
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"
  filename      = "lambda_function_payload.zip"
}

resource "aws_lambda_permission" "allow_s3_lambda_invoke" {
  statement_id  = "AllowS3InvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.lambda_trigger_bucket.arn
}

resource "aws_s3_bucket_notification" "lambda_trigger_notification" {
  bucket = aws_s3_bucket.lambda_trigger_bucket.bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_lambda.arn
    events       = ["s3:ObjectCreated:*"]
  }

  # Ensure that the Lambda permission is created before the notification
  depends_on = [
    aws_lambda_permission.allow_s3_lambda_invoke
  ]
}
