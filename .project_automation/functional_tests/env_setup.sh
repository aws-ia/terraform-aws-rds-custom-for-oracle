#!/bin/bash -e
export AWS_DEFAULT_REGION=us-west-2

#********** Get tfvars from SSM *************
echo "Generate tfvars from SSM parameter for rds-instance"
aws ssm get-parameter \
  --name "/abp/terraform-aws-rds-custom-for-oracle/cev/kms/key-id" \
  --with-decryption \
  --query "Parameter.Value" \
  --output "text" \
  --region $AWS_DEFAULT_REGION > ${PROJECT_PATH}/examples/rds-instance/terraform.tfvars


echo "Generate tfvars from SSM parameter for rds-instance-and-replica"
aws ssm get-parameter \
  --name "/abp/terraform-aws-rds-custom-for-oracle/cev/kms/key-id" \
  --with-decryption \
  --query "Parameter.Value" \
  --output "text" \
  --region $AWS_DEFAULT_REGION > ${PROJECT_PATH}/examples/rds-instance-and-replica/terraform.tfvars