<!-- BEGIN_TF_DOCS -->
# Creating primary RDS Custom for Oracle instance and two replicas in a VPC

This example shows how you can create a primary instance, and two replicas in your Amazon VPC. This example creates the following:

* RDS Custom for Oracle primary instance using a precreated Custom Engine Version (CEV)
* Two RDS Custom for Oracle replica instances from the primary
* VPC with thre private subnets

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_rds_custom_for_oracle"></a> [rds\_custom\_for\_oracle](#module\_rds\_custom\_for\_oracle) | ../.. | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | aws-ia/vpc/aws | >= 4.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_kms_key.by_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |
| [aws_rds_orderable_db_instance.custom-oracle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/rds_orderable_db_instance) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_db_instance_primary_arn"></a> [aws\_db\_instance\_primary\_arn](#output\_aws\_db\_instance\_primary\_arn) | Created RDS primary instance arn. |
| <a name="output_db_subnet_group"></a> [db\_subnet\_group](#output\_db\_subnet\_group) | Created RDS DB subnet group. |
| <a name="output_subnet_config"></a> [subnet\_config](#output\_subnet\_config) | Created subnets. |
<!-- END_TF_DOCS -->