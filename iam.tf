# Create combined IAM role for EC2 to access CloudWatch and S3
resource "aws_iam_role" "ec2_role" {
  name = "EC2CloudWatchS3Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach AWS managed policy for CloudWatch Agent
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Create custom S3 policy to allow read, write, and delete on the bucket
resource "aws_iam_policy" "s3_access_policy" {
  name        = "S3FullAccessPolicy"
  description = "Policy to allow EC2 full access to a specific S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.webapp_bucket.arn}/*"
      }
    ]
  })
  depends_on = [aws_s3_bucket.webapp_bucket]
}

# Attach S3 policy to role
resource "aws_iam_role_policy_attachment" "s3_access_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# Create an IAM policy for EC2 to access Secrets Manager and KMS
resource "aws_iam_policy" "ec2_secrets_manager_policy" {
  name        = "EC2SecretsManagerPolicy"
  description = "Policy to allow EC2 instance to retrieve secrets from Secrets Manager and use KMS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = aws_secretsmanager_secret.db_password.arn
      },
      {
        Effect   = "Allow"
        Action   = "kms:Decrypt"
        Resource = aws_kms_key.db_secrets_key.arn
      }
    ]
  })
}

# Attach the policy to the EC2 IAM role
resource "aws_iam_role_policy_attachment" "ec2_secrets_manager_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_secrets_manager_policy.arn
}

# Create IAM instance profile for the combined role
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "EC2InstanceProfileWithCloudWatchAndS3Access"
  role = aws_iam_role.ec2_role.name
}