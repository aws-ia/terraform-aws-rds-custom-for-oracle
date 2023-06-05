# Look up the instance type suppored for the CEV specified.
data "aws_rds_orderable_db_instance" "custom-oracle" {
  engine                     = "custom-oracle-ee" # CEV engine to be used
  engine_version             = "19.c.ee.cdb-2"    # CEV engine version to be used
  license_model              = "bring-your-own-license"
  storage_type               = "gp3"
  preferred_instance_classes = ["db.r5.24xlarge", "db.r5.16xlarge", "db.r5.12xlarge"]
}

# The RDS instances resource requires an ARN. Look up the ARN of the KMS key associated with the CEV.
data "aws_kms_key" "by_id" {
  key_id = var.kms_key_id_for_cev
}

module "rds_custom_for_oracle" {
  # source  = "aws-ia/rds-custom-for-oracle/aws"
  # version = ">= 1.0.0"
  source = "../.."

  vpc_id                         = module.vpc.vpc_attributes.id
  vpc_cidr                       = module.vpc.vpc_attributes.cidr_block
  private_subnet_route_table_ids = [for _, value in module.vpc.rt_attributes_by_type_by_az.private : value.id]
  private_subnet_config          = flatten([for _, value in module.vpc.private_subnet_attributes_by_az : {subnet_id = value.id, availability_zone = value.availability_zone}])

  kms_key_id = data.aws_kms_key.by_id.arn

  create_db_subnet_group = true # Toggle to create or assign db subnet group. Defaut name and description will be used.
  create_vpc_endpoints   = true # Toggle to create or not the VPC endpoints. Defaut name and description will be used.

  create_iam_role             = true # Toggle to create or assign IAM role. Defaut name and description will be used.
  create_iam_instance_profile = true # Toggle to create or assign IAM instance profile. Defaut name will be used.

  aws_db_instance_primary = {
    apply_immediately       = true
    allocated_storage       = 50
    backup_retention_period = 30
    db_name                 = "ORCL"
    engine                  = data.aws_rds_orderable_db_instance.custom-oracle.engine
    engine_version          = data.aws_rds_orderable_db_instance.custom-oracle.engine_version
    identifier              = "instance-standalone"
    instance_class          = data.aws_rds_orderable_db_instance.custom-oracle.instance_class
    username                = "dbadmin"
    password                = "avoid-plaintext-passwords"
    skip_final_snapshot     = true
  }
  tags = {
    CostCenter = "example-inc:cost-allocation:CostCenter"
  }

  # explict dependency on the VPC module, as module.vpc.aws_route_table_association.private[*] are required for full lifecycle operations
  depends_on = [module.vpc]
}

output "subnet_config" {
  description = "Created subnets."
  value       = flatten([for _, value in module.vpc.private_subnet_attributes_by_az : {subnet_id = value.id, availability_zone = value.availability_zone}])
}

output "aws_db_instance_primary_arn" {
  description = "Created RDS primary instance arn."
  value       = module.rds_custom_for_oracle.aws_db_instance_primary_attributes.arn
}

output "db_subnet_group" {
  description = "Created RDS DB subnet group."
  value       = module.rds_custom_for_oracle.db_subnet_group
}

# Create a VPC and subnets to deploy the RDS instance and replicas
module "vpc" {
  source  = "aws-ia/vpc/aws"
  version = ">= 4.0.0"

  name       = "multi-az-vpc-01"
  cidr_block = "10.1.0.0/20"
  az_count   = 2

  subnets = {
    private = { netmask = 24 }
  }
}

# KMS key associated with the CEV
variable "kms_key_id_for_cev" {
  type = string
}

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}