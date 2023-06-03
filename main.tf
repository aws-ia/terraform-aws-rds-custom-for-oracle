
#-------------------------------
# Database Subnet Group
#-------------------------------

resource "aws_db_subnet_group" "rdscustom" {
  count = var.create_db_subnet_group ? 1 : 0

  name        = local.db_subnet_group_name != null ? local.db_subnet_group_name : null
  name_prefix = local.db_subnet_group_name != null ? null : "awsrdscustom"
  description = var.db_subnet_group_description
  subnet_ids  = local.private_subnet_ids
  tags        = var.tags
}

#tfsec:ignore:aws-rds-enable-performance-insights AWS RDS Custom for Oracle does not support Performance Insights
resource "aws_db_instance" "primary" {
  # Security and best practice checks suppression
  # bridgecrew:skip=CKV_AWS_118:Enhanced monitoring is not supported with RDS Custom for Oracle
  # bridgecrew:skip=CKV_AWS_129:CloudWatch Logs exports is not supported with RDS Custom for Oracle
  # bridgecrew:skip=CKV_AWS_226:ClouAutoMinorVersionUpgrade is not supported with RDS Custom for Oracle, requires AutoMinorVersionUpgrade set to false.
  # bridgecrew:skip=CKV_AWS_353:Performance insight not supported for AWS RDS Custom for Oracle
  # bridgecrew:skip=CKV_AWS_354:Performance insight not supported for AWS RDS Custom for Oracle
  

  allocated_storage           = try(var.aws_db_instance_primary.allocated_storage, null)
  auto_minor_version_upgrade  = false # RDS Custom for Oracle requires AutoMinorVersionUpgrade set to false.
  apply_immediately           = try(var.aws_db_instance_primary.apply_immediately, null)
  availability_zone           = local.primary_placement_specified == true ? var.aws_db_instance_primary.availability_zone : local.private_subnet_azs[0]
  backup_retention_period     = try(var.aws_db_instance_primary.backup_retention_period, null)
  custom_iam_instance_profile = local.iam_instance_profile_name
  backup_window               = try(var.aws_db_instance_primary.backup_window, null)
  copy_tags_to_snapshot       = try(var.aws_db_instance_primary.copy_tags_to_snapshot, null)
  deletion_protection         = try(var.aws_db_instance_primary.deletion_protection, null) #tfsec:ignore:aws-rds-enable-deletion-protection
  db_name                     = try(var.aws_db_instance_primary.db_name, null)
  db_subnet_group_name        = local.db_subnet_group
  engine                      = try(var.aws_db_instance_primary.engine, null)
  engine_version              = try(var.aws_db_instance_primary.engine_version, null)
  final_snapshot_identifier   = try(var.aws_db_instance_primary.final_snapshot_identifier, null)
  identifier                  = try(var.aws_db_instance_primary.identifier, null)
  instance_class              = try(var.aws_db_instance_primary.instance_class, null)
  iops                        = try(var.aws_db_instance_primary.iops, null)
  kms_key_id                  = local.key_arn            # Resource requires an Arn, but the module accepts any KMS key Id
  license_model               = "bring-your-own-license" # Required for RDS Custom for Oracle
  maintenance_window          = try(var.aws_db_instance_primary.maintenance_window, null)
  network_type                = try(var.aws_db_instance_primary.network_type, null)
  multi_az                    = false # Not supported with RDS Custom for Oracle
  password                    = try(var.aws_db_instance_primary.password, null)
  port                        = try(var.aws_db_instance_primary.port, null)
  publicly_accessible         = try(var.aws_db_instance_primary.publicly_accessible, null)
  skip_final_snapshot         = try(var.aws_db_instance_primary.skip_final_snapshot, null)
  storage_type                = try(var.aws_db_instance_primary.storage_type, null)
  storage_encrypted           = true # Required for RDS Custom for Oracle
  username                    = try(var.aws_db_instance_primary.username, null)
  vpc_security_group_ids      = toset(try(var.aws_db_instance_primary.vpc_security_group_ids, null))
  tags                        = var.tags
  /*
  RDS instance creation and configuration requires that the VPC endpoints and IAM instance profile be created first.
  */
  depends_on = [
    module.private_link_endpoints
  ]

  timeouts {
    create = try(var.timeout.create, "4h")
    delete = try(var.timeout.delete, "4h")
    update = try(var.timeout.update, "4h")
  }
}

resource "aws_db_instance" "replicas" {
  count = local.create_replicas ? var.aws_db_instance_replicas.replica_count : 0
  # Security and best practice checks suppression
  # bridgecrew:skip=CKV_AWS_118:Enhanced monitoring is not supported with RDS Custom for Oracle
  # bridgecrew:skip=CKV_AWS_129:CloudWatch Logs exports is not supported with RDS Custom for Oracle
  # bridgecrew:skip=CKV_AWS_226:ClouAutoMinorVersionUpgrade is not supported with RDS Custom for Oracle, requires AutoMinorVersionUpgrade set to false.
  # bridgecrew:skip=CKV_AWS_353:Performance insight not supported for AWS RDS Custom for Oracle
  # bridgecrew:skip=CKV_AWS_354:Performance insight not supported for AWS RDS Custom for Oracle
  
  replicate_source_db = try(var.aws_db_instance_replicas.identifier, aws_db_instance.primary.identifier)
  replica_mode        = "mounted"

  allocated_storage          = try(var.aws_db_instance_replicas.allocated_storage, null)
  auto_minor_version_upgrade = false # RDS Custom for Oracle requires AutoMinorVersionUpgrade set to false.
  apply_immediately          = try(var.aws_db_instance_replicas.apply_immediately, null)
  # If not specified, replicas will be placed in subnets separate from the primary by default (primary placed into the first subnet).
  # If specified, availability_zones will be applied in order to the replicas.
  # If the number of availability_zones is less than the number of replicas, the availability_zones will be applied in order until the last availability_zone is reached.
  availability_zone           = local.replica_placement_specified == true ? try(var.aws_db_instance_replicas.availability_zones[count.index], null) : try(local.private_subnet_azs[count.index + 1], null)
  backup_retention_period     = try(var.aws_db_instance_replicas.backup_retention_period, null)
  custom_iam_instance_profile = local.iam_instance_profile_name
  backup_window               = try(var.aws_db_instance_replicas.backup_window, null)
  copy_tags_to_snapshot       = try(var.aws_db_instance_replicas.copy_tags_to_snapshot, null)
  # db_subnet_group_name        = local.db_subnet_group  // DBSubnetGroupNotAllowedFault: DbSubnetGroupName should not be specified for read replicas that are created in the same region as the master
  final_snapshot_identifier = try(var.aws_db_instance_replicas.final_snapshot_identifier, null)
  identifier                = local.replica_identifiers_specified == true ? try(var.aws_db_instance_replicas.identifiers[count.index]) : "${var.aws_db_instance_primary.identifier}-replica-${count.index}"
  instance_class            = try(var.aws_db_instance_replicas.instance_class, null)
  iops                      = try(var.aws_db_instance_replicas.iops, null)
  kms_key_id                = local.key_arn            # Resource requires an Arn, but the module accepts any KMS key Id
  license_model             = "bring-your-own-license" # Required for RDS Custom for Oracle
  maintenance_window        = try(var.aws_db_instance_replicas.maintenance_window, null)
  network_type              = try(var.aws_db_instance_replicas.network_type, null)
  multi_az                  = false # Not supported with RDS Custom for Oracle
  port                      = try(var.aws_db_instance_replicas.port, null)
  publicly_accessible       = try(var.aws_db_instance_replicas.publicly_accessible, null)
  skip_final_snapshot       = try(var.aws_db_instance_replicas.skip_final_snapshot, null)
  storage_type              = try(var.aws_db_instance_replicas.storage_type, null)
  storage_encrypted         = true # Required for RDS Custom for Oracle
  vpc_security_group_ids    = toset(try(var.aws_db_instance_replicas.vpc_security_group_ids, null))
  tags                      = var.tags
  /*
  RDS instance creation and configuration requires that the VPC endpoints and IAM instance profile be created first.
  */
  depends_on = [
    module.private_link_endpoints,
    aws_db_instance.aws_db_instance.primary
  ]

  timeouts {
    create = try(var.timeout.create, "4h")
    delete = try(var.timeout.delete, "4h")
    update = try(var.timeout.update, "4h")
  }
}


#-------------------------------
# Endpoints
#-------------------------------
module "private_link_endpoints" {
  source = "./modules/endpoints"

  count = var.create_vpc_endpoints ? 1 : 0

  vpc_id                         = var.vpc_id
  vpc_cidr                       = var.vpc_cidr
  private_subnet_ids             = local.private_subnet_ids
  private_subnet_route_table_ids = var.private_subnet_route_table_ids

  create_endpoint_security_group      = var.create_endpoint_security_group
  endpoint_security_group_name        = try(var.endpoint_security_group_name, null)
  endpoint_security_group_description = try(var.endpoint_security_group_description, null)
  endpoint_security_group_id          = try(var.endpoint_security_group_id, null)

  tags = var.tags
}
