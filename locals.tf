locals {
  create_db_subnet_group = var.create_db_subnet_group
  db_subnet_group_name   = var.db_subnet_group_name
  db_subnet_group        = local.create_db_subnet_group ? aws_db_subnet_group.rdscustom[0].name : var.db_subnet_group

  private_subnet_config = var.private_subnet_config
  private_subnet_ids    = local.private_subnet_config[*].subnet_id
  private_subnet_azs    = local.private_subnet_config[*].availability_zone

  create_iam_role = var.create_iam_role
  iam_role_name   = local.create_iam_role ? aws_iam_role.rdscustom[0].name : split("role/", var.iam_role_arn)[1]

  create_iam_instance_profile = var.create_iam_instance_profile
  iam_instance_profile_name   = local.create_iam_instance_profile ? aws_iam_instance_profile.rdscustom[0].name : split("instance-profile/", var.iam_instance_profile_arn)[1]

  create_replicas               = try(var.aws_db_instance_replicas.replica_count, 0) > 0 ? true : false
  replica_identifiers_specified = local.create_replicas && try(var.aws_db_instance_replicas.identifiers, false) == true ? true : false
  primary_placement_specified   = try(var.aws_db_instance_primary.availability_zone, false) == true ? true : false
  replica_placement_specified   = local.create_replicas && try(var.aws_db_instance_replicas.availability_zones, false) == true ? true : false

  key_arn = data.aws_kms_key.by_id.arn
}


