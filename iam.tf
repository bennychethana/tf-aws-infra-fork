# Create IAM role for EC2 to use CloudWatch
resource "aws_iam_role" "cloudwatch_agent_role" {
  name = "CloudWatchAgentServerRole"

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
  role       = aws_iam_role.cloudwatch_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Create IAM instance profile
resource "aws_iam_instance_profile" "cloudwatch_agent_profile" {
  name = "CloudWatchAgentServerProfile"
  role = aws_iam_role.cloudwatch_agent_role.name
}

# --------
# resource "aws_iam_policy" "CSYE6225_Custome_Policy" {
#   depends_on = [
#     aws_s3_bucket.webapp_bucket
#   ]
 
#   name = "WebAppPolicy"
 
#   policy = jsonencode(
#     {
#       "Version" : "2012-10-17",
#       "Statement" : [
#         {
#           "Action" : [
#             "s3:PutObject",
#             "s3:GetObject",
#             "s3:DeleteObject"
#           ],
#           "Effect" : "Allow",
#           "Resource" : [
#             "arn:aws:s3:::${aws_s3_bucket.webapp_bucket.bucket}",
#             "arn:aws:s3:::${aws_s3_bucket.webapp_bucket.bucket}/*"
#           ]
#         }
#       ]
#     }
#   )
# }
 
# resource "aws_iam_role" "CSYE6225_Role" {
#   name = "CSYE6225_Role"
 
#   depends_on = [
#     aws_s3_bucket.webapp_bucket
#   ]
 
#   assume_role_policy = <<EOF
#     {
#         "Version": "2012-10-17",
#         "Statement": [
#             {
#             "Action": "sts:AssumeRole",
#             "Principal": {
#                 "Service": "ec2.amazonaws.com"
#             },
#             "Effect": "Allow",
#             "Sid": ""
#             }
#         ]
#     }
# EOF
 
#   tags = {
#     "Name" = "csye6225_role"
#   }
# }
 
# resource "aws_iam_role_policy_attachment" "policy-attach" {
#   role       = aws_iam_role.CSYE6225_Role.name
#   policy_arn = aws_iam_policy.CSYE6225_Custome_Policy.arn
# }
 
# resource "aws_iam_role_policy_attachment" "policy-attach2" {
#   role       = aws_iam_role.CSYE6225_Role.name
#   policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
# }
 
# resource "aws_iam_instance_profile" "CSYE6225-profile" {
#   name = "iam-profile"
#   role = aws_iam_role.CSYE6225_Role.name
# }