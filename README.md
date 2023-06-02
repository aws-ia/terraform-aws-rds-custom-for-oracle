<!-- BEGIN_TF_DOCS -->
# AWS RDS Custom for Oracle Module

This module provides prescriptive deployment for [RDS Custom for Oracle](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/working-with-custom-oracle.html). This module provides the ability to create primary instances and associated replicas.

Common deployment examples can be found in [examples/](./examples).

## This module creates the following resources:

* RDS Custom for Oracle primary instance using a precreated [Custom Engine Version (CEV)](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/custom-cev.html)
* (optional) [RDS Custom for Oracle replcia instance(s)](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/custom-rr.html) from the primary
* (optional) [IAM Role and Instance Profile](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/custom-setup-orcl.html#custom-setup-orcl.iam-vpc) for the primary and replicas
* (optional) [DBSubnet Group](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/custom-setup-orcl.html#custom-setup-orcl.iam-vpc) for the primary and replicas
* (optional) [Security Group](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/custom-setup-orcl.html#custom-setup-orcl.iam-vpc) for the VPC endpoints, allowing the primary and replica instance(s) to communicate with dependent AWS services
* (optional) VPC endpoints, which are rquired for primary and replica instance(s) to communicate with dependent AWS services:
    * com.amazonaws.region.s3
    * com.amazonaws.region.ec2
    * com.amazonaws.region.ec2messages
    * com.amazonaws.region.monitoring
    * com.amazonaws.region.ssm
    * com.amazonaws.region.ssmmessages
    * com.amazonaws.region.logs
    * com.amazonaws.region.events
    * com.amazonaws.region.secretsmanager

## Prerequisites

RDS Custom for Oracle requires a [Custom Engine Version (CEV)](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/custom-cev.html) to be created before creating the primary instance. The CEV must be created in the same region as the primary instance. The CEV must be created using customer managed symmetric AWS KMS Key.

For more information on RDS Custom for Oracle prerequisites, see [Prerequisites for using Amazon RDS Custom for Oracle](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/custom-setup-orcl.html).

For more information on creating a CEV, see [Creating a Custom Engine Version](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/custom-cev.create.html).

## Availability Zones

If not specified, primariy instances will be placed in the first subnet provided to `subnet_config`. Replicas will be placed in subnets separate from the primary, starting with the second subnet.

To specify the placement to specific availability zones for the primary and replicas, use the `aws_db_instance_primary.availability_zone` and `aws_db_instance_replicas.availability_zones` attribute(s). If specifified, availability\_zones will be applied in order to the replicas.

## IAM Role and Instance Profile

If not specified, the module will create an IAM role and instance profile for the primary and replicas.

To specify the IAM role and instance profile, use the `iam_role_arn` and `iam_instance_profile_arn` attributes. The role name and instance profile name must start with `AWSRDSCustom`.

```hcl
  create_iam_role             = false # Toggle to create or assign IAM role. Defaut name and description will be used.
  iam_role_arn                = "arn:aws:iam::123456789012:role/AWSRDSCustomInstanceRole-us-west-2"
  create_iam_instance_profile = false # Toggle to create or assign IAM instance profile. Defaut name and description will be used.
  iam_instance_profile_arn    = "arn:aws:iam::123456789012:instance-profile/AWSRDSCustomInstanceProfile-us-west-2"
```

## Contributing

Please see our [developer documentation](https://github.com/aws-ia/terraform-aws-vpc/blob/main/contributing.md) for guidance on contributing to this module.

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
| <a name="module_private_link_endpoints"></a> [private\_link\_endpoints](#module\_private\_link\_endpoints) | ./modules/endpoints | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_instance.replicas](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.rdscustom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_iam_instance_profile.rdscustom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.rdscustom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy.ssm_managed_default_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_kms_key.by_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_db_instance_primary"></a> [aws\_db\_instance\_primary](#input\_aws\_db\_instance\_primary) | Primary instance configuration values. Map where the key is the argument. For examples, see /examples/ folder.<br>/*<br>aws\_db\_instance\_primary = {<br>  allocated\_storage = 50<br>  apply\_immediately = false<br>  ...<br>}<br>*/ | <pre>object({<br>    allocated_storage         = optional(number)<br>    apply_immediately         = optional(bool)<br>    availability_zone         = optional(string)<br>    backup_retention_period   = number<br>    backup_window             = optional(string)<br>    copy_tags_to_snapshot     = optional(bool)<br>    db_name                   = string<br>    delete_automated_backups  = optional(bool)<br>    deletion_protection       = optional(bool)<br>    engine                    = string<br>    engine_version            = string<br>    final_snapshot_identifier = optional(string)<br>    identifier                = string<br>    instance_class            = string<br>    iops                      = optional(number)<br>    maintenance_window        = optional(string)<br>    network_type              = optional(string)<br>    password                  = string<br>    port                      = optional(number)<br>    publicly_accessible       = optional(bool)<br>    skip_final_snapshot       = optional(bool)<br>    storage_type              = optional(string)<br>    username                  = string<br>    vpc_security_group_ids    = optional(list(string))<br>  })</pre> | n/a | yes |
| <a name="input_private_subnet_config"></a> [private\_subnet\_config](#input\_private\_subnet\_config) | List of private subnets configurations for the RDS instance and replicas. Will be applied in order to the instance first, and then replicas. | <pre>list(object({<br>    subnet_id         = string<br>    availability_zone = string<br>  }))</pre> | n/a | yes |
| <a name="input_private_subnet_route_table_ids"></a> [private\_subnet\_route\_table\_ids](#input\_private\_subnet\_route\_table\_ids) | List of private subnets route tables in which to associate the gateway endpoints. | `list(string)` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC CIDR for the endpoints to communicate with. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC Id. | `string` | n/a | yes |
| <a name="input_aws_db_instance_replicas"></a> [aws\_db\_instance\_replicas](#input\_aws\_db\_instance\_replicas) | Replica instance(s) configuration values. Map where the key is the argument. For examples, see /examples/ folder.<br><br>Replicas will be placed in subnets separate from the primary by default.<br>If specifified, availability\_zones will be applied in order to the replicas. If the number of availability\_zones is less than the number of replicas, the availability\_zones will be applied in order until the last availability\_zone is reached.<br>if specified, identifiers will be applied in order to the replicas. If the number of identifiers is less than the number of replicas, the identifiers will be applied in order until the last identifier is reached, and then default indentifiers will be applied.<br><br>/*<br>aws\_db\_instance\_primary = {<br>  replica\_count      = 2<br>  availability\_zones = ["us-east-1a", "us-east-1b"]<br>  identifiers        = ["replica-01", "replica-03"]<br>  replicate\_source\_db = "instance-01"<br>  ...<br>}<br>*/ | <pre>object({<br>    replica_count             = number<br>    allocated_storage         = optional(number)<br>    apply_immediately         = optional(bool)<br>    availability_zones        = optional(list(string))<br>    backup_retention_period   = optional(number)<br>    backup_window             = optional(string)<br>    copy_tags_to_snapshot     = optional(bool)<br>    delete_automated_backups  = optional(bool)<br>    final_snapshot_identifier = optional(string)<br>    identifiers               = optional(list(string))<br>    instance_class            = string<br>    iops                      = optional(number)<br>    maintenance_window        = optional(string)<br>    network_type              = optional(string)<br>    port                      = optional(number)<br>    replicate_source_db       = optional(number)<br>    publicly_accessible       = optional(bool)<br>    skip_final_snapshot       = optional(bool)<br>    storage_type              = optional(string)<br>    vpc_security_group_ids    = optional(list(string))<br>  })</pre> | <pre>{<br>  "instance_class": "",<br>  "replica_count": 0<br>}</pre> | no |
| <a name="input_create_db_subnet_group"></a> [create\_db\_subnet\_group](#input\_create\_db\_subnet\_group) | Toggle to create or assign db subnet group. | `bool` | `true` | no |
| <a name="input_create_endpoint_security_group"></a> [create\_endpoint\_security\_group](#input\_create\_endpoint\_security\_group) | Toggle to create or assign endpoint security group. | `bool` | `true` | no |
| <a name="input_create_iam_instance_profile"></a> [create\_iam\_instance\_profile](#input\_create\_iam\_instance\_profile) | Toggle to create or assign IAM instance profile. | `bool` | `true` | no |
| <a name="input_create_iam_role"></a> [create\_iam\_role](#input\_create\_iam\_role) | Toggle to create or assign IAM role. | `bool` | `true` | no |
| <a name="input_create_vpc_endpoints"></a> [create\_vpc\_endpoints](#input\_create\_vpc\_endpoints) | Toggle to create vpc endpoints. | `bool` | `true` | no |
| <a name="input_db_subnet_group"></a> [db\_subnet\_group](#input\_db\_subnet\_group) | DB Subnet Group to be used. Required if `create_db_subnet_group` is set to `false`. | `string` | `""` | no |
| <a name="input_db_subnet_group_description"></a> [db\_subnet\_group\_description](#input\_db\_subnet\_group\_description) | Description of the db subnet group created. | `string` | `"DB subnet group for RDSCustomForOracle"` | no |
| <a name="input_db_subnet_group_name"></a> [db\_subnet\_group\_name](#input\_db\_subnet\_group\_name) | Name of db subnet group created. | `string` | `null` | no |
| <a name="input_endpoint_security_group_description"></a> [endpoint\_security\_group\_description](#input\_endpoint\_security\_group\_description) | Description of the endpoint security group created. | `string` | `"Endpoint security group"` | no |
| <a name="input_endpoint_security_group_id"></a> [endpoint\_security\_group\_id](#input\_endpoint\_security\_group\_id) | Security group to be used. Required if `create_endpoint_security_group` is set to `false`. | `string` | `""` | no |
| <a name="input_endpoint_security_group_name"></a> [endpoint\_security\_group\_name](#input\_endpoint\_security\_group\_name) | Name of endpoint security group created. | `string` | `null` | no |
| <a name="input_iam_instance_profile_arn"></a> [iam\_instance\_profile\_arn](#input\_iam\_instance\_profile\_arn) | IAM instance profile to be used. Required if `create_iam_instance_profile` is set to `false`. | `string` | `null` | no |
| <a name="input_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#input\_iam\_instance\_profile\_name) | Name of IAM instance profile created. | `string` | `null` | no |
| <a name="input_iam_instance_profile_path"></a> [iam\_instance\_profile\_path](#input\_iam\_instance\_profile\_path) | IAM instance profile path. | `string` | `null` | no |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | IAM role to be used. Required if `create_iam_role` is set to `false`. | `string` | `null` | no |
| <a name="input_iam_role_description"></a> [iam\_role\_description](#input\_iam\_role\_description) | Description of the role. | `string` | `"Role for RDS Custom for Oracle"` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name to use on IAM role created. | `string` | `null` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | IAM role path. | `string` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS Customer Managed Key Id. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('example-inc:cost-allocation:CostCenter','XYZ'`). | `map(string)` | `{}` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Optional nested block of timeout values. For examples, see /examples/ folder.<br>/*<br>timeout = {<br>  create = "4h"<br>  delete = "4h"<br>  update = "4h"<br>}<br>*/ | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_db_instance_primary_attributes"></a> [aws\_db\_instance\_primary\_attributes](#output\_aws\_db\_instance\_primary\_attributes) | DBInstance resource attributes. Full output of aws\_db\_instance. |
| <a name="output_aws_db_instance_replicas_attributes"></a> [aws\_db\_instance\_replicas\_attributes](#output\_aws\_db\_instance\_replicas\_attributes) | DBInstance resource attributes. Full output of aws\_db\_instance. |
| <a name="output_db_subnet_group"></a> [db\_subnet\_group](#output\_db\_subnet\_group) | RDS DB subnet group. |
| <a name="output_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#output\_iam\_instance\_profile\_name) | RDS IAM instance profile. |
| <a name="output_iam_role"></a> [iam\_role](#output\_iam\_role) | RDS IAM role. |
<!-- END_TF_DOCS -->