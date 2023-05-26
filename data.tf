data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy" "ssm_managed_default_policy" {
  name = "AmazonSSMManagedEC2InstanceDefaultPolicy"
}

data "aws_kms_key" "by_id" {
  key_id = var.kms_key_id # KMS key associated with the CEV, can use data source to retrieve Arn as required by aws_db_instance
}
