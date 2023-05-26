#-------------------------------
# Create IAM Instance Profile
#-------------------------------
resource "aws_iam_instance_profile" "rdscustom" {
  count = local.create_iam_instance_profile ? 1 : 0

  name        = var.iam_instance_profile_name != null ? var.iam_instance_profile_name : null
  name_prefix = var.iam_instance_profile_name == null ? "AWSRDSCustomInstanceProfile-" : null
  path        = var.iam_instance_profile_path
  role        = local.iam_role_name

  tags = var.tags
}


#-------------------------------
# Create IAM Role
#-------------------------------
resource "aws_iam_role" "rdscustom" {
  count = local.create_iam_role ? 1 : 0

  name        = var.iam_role_name != null ? var.iam_role_name : null
  name_prefix = var.iam_role_name == null ? "AWSRDSCustomRole-" : null
  description = var.iam_role_description
  path        = var.iam_role_path
  tags        = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  # SSM managed policy
  managed_policy_arns = [data.aws_iam_policy.ssm_managed_default_policy.arn]

  # policy that can write to cloudwatch logs, s3 and cloudwatchputdata
  inline_policy {
    name = "RDSCustomForOracle"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid = "AllowRDSCustomToWriteToCloudWatchLogs"
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:DescribeLogStreams",
            "logs:DescribeLogGroups",
            "logs:PutLogEvents",
            "logs:PutRetentionPolicy"
          ]
          Effect   = "Allow"
          Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:rds-custom-instance*"
        },
        {
          Sid = "AllowRDSCustomInstanceToWriteToS3"
          Action = [
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:PutObject"
          ]
          Effect   = "Allow"
          Resource = ["arn:aws:s3:::do-not-delete-rds-custom-*/*"]
        },
        {
          Sid = "AllowRDSCustomInstanceToReadS3"
          Action = [
            "s3:ListBucketVersions"
          ]
          Effect   = "Allow"
          Resource = ["arn:aws:s3:::do-not-delete-rds-custom-*"]
        },
        {
          Sid = "AllowRDSCustomToWriteToCloudWatchPutData"
          Action = [
            "cloudwatch:PutMetricData"
          ]
          Effect   = "Allow"
          Resource = "*"
          Condition = {
            StringEquals = {
              "cloudwatch:namespace" = "RDSCustomForOracle/Agent"
            }
          }
        },
        {
          Sid = "AllowRDSCustomToWriteToEventBridge"
          Action = [
            "events:PutEvents"
          ]
          Effect   = "Allow"
          Resource = ["*"]
        },
        {
          Sid = "AllowRDSCustomToReadSSM"
          Action = [
            "ssm:GetConnectionStatus",
            "ssm:DescribeInstanceInformation",
            "ssm:GetParameters",
            "ssm:GetParameter"
          ]
          Effect   = "Allow"
          Resource = ["*"]
        },
        {
          Sid = "AllowRDSCustomToReadSecretsManager"
          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ],
          Effect   = "Allow"
          Resource = "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:do-not-delete-rds-custom-*"
        },
        {
          Sid = "AllowRDSCustomToCreateInstanceVolumeSnapshots"
          Action = [
            "ec2:CreateSnapshots"
          ]
          Effect   = "Allow"
          Resource = ["arn:aws:ec2:*:*:instance/*", "arn:aws:ec2:*:*:volume/*"]
          Condition = {
            StringEquals = {
              "ec2:ResourceTag/AWSRDSCustom" = "custom-oracle"
            }
          }
        },
        {
          Sid = "AllowRDSCustomToCreateSnapshots"
          Action = [
            "ec2:CreateSnapshots"
          ]
          Effect   = "Allow"
          Resource = ["arn:aws:ec2:*::snapshot/*"]
        },
        {
          Sid = "AllowRDSCustomToDecrypt"
          Action = [
            "kms:Decrypt",
            "kms:GenerateDataKey"
          ]
          Effect   = "Allow"
          Resource = var.kms_key_id
        },
        {
          Sid = "AllowRDSCustomToCreateTags"
          Action = [
            "ec2:CreateTags"
          ]
          Effect   = "Allow"
          Resource = ["*"]
          Condition = {
            StringLike = {
              "ec2:CreateAction" = "CreateSnapshots"
            }
          }
        }
      ]
    })
  }
}