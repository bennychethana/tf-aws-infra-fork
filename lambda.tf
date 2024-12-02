resource "aws_secretsmanager_secret" "email_credentials" {
  name                    = "email-service-credentials-fixed"
  recovery_window_in_days = 0
  kms_key_id              = aws_kms_key.email_secrets_key.key_id
}

resource "aws_secretsmanager_secret_version" "email_credentials" {
  secret_id = aws_secretsmanager_secret.email_credentials.id
  secret_string = jsonencode({
    SENDGRID_API_KEY = var.sendgrid_api_key
    WEBAPP_DOMAIN    = var.domain_name
  })
}

resource "aws_lambda_function" "user_verification_lambda" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = var.lambda_function_handler
  runtime       = var.lambda_function_runtime

  timeout     = 60
  memory_size = 128

  # Reference the Lambda code from the local file
  filename = "${path.module}/${var.lambda_file_path}"

  # Or Reference the Lambda code from S3 with dynamic file name
  #   s3_bucket = "myawsbucketbenny"
  #   s3_key    = var.lambda_file_path

  // Commenting as we are using secrets manager now 
  # environment {
  #   variables = {
  #     SENDGRID_API_KEY = var.sendgrid_api_key
  #     WEBAPP_DOMAIN    = var.domain_name
  #   }
  # }

}

resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.user_verification_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.user_verification_topic.arn
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "sns_publish_policy" {
  name        = "sns-publish-policy"
  description = "Policy to allow EC2 instance to publish to SNS topic"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sns:Publish",
        "Resource" : aws_sns_topic.user_verification_topic.arn
      }
    ]
  })
}

# Attach SNS publish policy to the EC2 role
resource "aws_iam_role_policy_attachment" "attach_sns_publish_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.sns_publish_policy.arn
}

resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name        = "cloudwatch-logs-policy"
  description = "Policy to allow Lambda to create and write logs to CloudWatch"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_cloudwatch_logs_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}

# Create an IAM policy for Lambda to access Secrets Manager and KMS
resource "aws_iam_policy" "lambda_secrets_manager_policy" {
  name        = "LambdaSecretsManagerPolicy"
  description = "Policy to allow Lambda function to retrieve secrets from Secrets Manager and use KMS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = aws_secretsmanager_secret.email_credentials.arn
      },
      {
        Effect   = "Allow"
        Action   = "kms:Decrypt"
        Resource = aws_kms_key.email_secrets_key.arn
      }
    ]
  })
}

# Attach the policy to the Lambda IAM role
resource "aws_iam_role_policy_attachment" "lambda_secrets_manager_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_secrets_manager_policy.arn
}
