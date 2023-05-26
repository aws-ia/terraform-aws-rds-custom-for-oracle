
#-------------------------------
# VPC for RDS Instance
#-------------------------------
variable "vpc_id" {
  description = "VPC Id."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR for the endpoints to communicate with."
  type        = string
}

variable "private_subnet_config" {
  description = "List of private subnets configurations for the RDS instance and replicas. Will be applied in order to the instance first, and then replicas."
  type = list(object({
    subnet_id         = string
    availability_zone = string
  }))
  validation {
    condition     = length(var.private_subnet_config) >= 2
    error_message = "At least two private subnets id must be provided."
  }
}

variable "private_subnet_route_table_ids" {
  description = "List of private subnets route tables in which to associate the gateway endpoints."
  type        = list(string)
}

#-------------------------------
# KMS Customer Managed Key
#-------------------------------
variable "kms_key_id" {
  description = "KMS Customer Managed Key Id."
  type        = string
  default     = ""
}

#-------------------------------
# Database Subnet Group
#-------------------------------
variable "create_db_subnet_group" {
  description = "Toggle to create or assign db subnet group."
  type        = bool
  default     = true
}

variable "db_subnet_group_name" {
  description = "Name of db subnet group created."
  type        = string
  default     = null
}

variable "db_subnet_group_description" {
  description = "Description of the db subnet group created."
  type        = string
  default     = "DB subnet group for RDSCustomForOracle"
}

variable "db_subnet_group" {
  description = "DB Subnet Group to be used. Required if `create_db_subnet_group` is set to `false`."
  type        = string
  default     = ""
}


#-------------------------------
# VPC Endpoints
#-------------------------------
variable "create_vpc_endpoints" {
  description = "Toggle to create vpc endpoints."
  type        = bool
  default     = true
}

#-------------------------------
# VPC EndPoints Security Group
#-------------------------------
variable "create_endpoint_security_group" {
  description = "Toggle to create or assign endpoint security group."
  type        = bool
  default     = true
}

variable "endpoint_security_group_name" {
  description = "Name of endpoint security group created."
  type        = string
  default     = null
}

variable "endpoint_security_group_description" {
  description = "Description of the endpoint security group created."
  type        = string
  default     = "Endpoint security group"
}

variable "endpoint_security_group_id" {
  description = "Security group to be used. Required if `create_endpoint_security_group` is set to `false`."
  type        = string
  default     = ""
}

#-------------------------------
# RDS IAM Role
#-------------------------------

variable "create_iam_role" {
  description = "Toggle to create or assign IAM role."
  type        = bool
  default     = true
}

variable "iam_role_name" {
  description = "Name to use on IAM role created."
  type        = string
  default     = null
}

variable "iam_role_path" {
  description = "IAM role path."
  type        = string
  default     = null
}

variable "iam_role_description" {
  description = "Description of the role."
  type        = string
  default     = "Role for RDS Custom for Oracle"
}

variable "iam_role_arn" {
  description = "IAM role to be used. Required if `create_iam_role` is set to `false`."
  type        = string
  default     = null
}


#-------------------------------
# RDS Instance Profile
#-------------------------------
variable "create_iam_instance_profile" {
  description = "Toggle to create or assign IAM instance profile."
  type        = bool
  default     = true
}

variable "iam_instance_profile_name" {
  description = "Name of IAM instance profile created."
  type        = string
  default     = null

  validation {
    condition     = can(regex("^AWSRDSCustom", var.iam_instance_profile_name)) || var.iam_instance_profile_name == null
    error_message = "Instance profile name must start with `AWSRDSCustom`."
  }
}

variable "iam_instance_profile_path" {
  description = "IAM instance profile path."
  type        = string
  default     = null
}

variable "iam_instance_profile_arn" {
  description = "IAM instance profile to be used. Required if `create_iam_instance_profile` is set to `false`."
  type        = string
  default     = null

  validation {
    condition     = can(regex("AWSRDSCustom", var.iam_instance_profile_arn)) || var.iam_instance_profile_arn == null
    error_message = "Instance profile required. Instance profile name must start with `AWSRDSCustom`."
  }
}

#-------------------------------
# RDS Instance Primary
#-------------------------------
variable "aws_db_instance_primary" {
  description = <<-EOF
  Primary instance configuration values. Map where the key is the argument. For examples, see /examples/ folder.
  /*
  aws_db_instance_primary = {
    allocated_storage = 50
    apply_immediately = false
    ...
  }
  */
EOF

  type = object({
    allocated_storage         = optional(number)
    apply_immediately         = optional(bool)
    availability_zone         = optional(string)
    backup_retention_period   = number
    backup_window             = optional(string)
    copy_tags_to_snapshot     = optional(bool)
    db_name                   = string
    delete_automated_backups  = optional(bool)
    deletion_protection       = optional(bool)
    engine                    = string
    engine_version            = string
    final_snapshot_identifier = optional(string)
    identifier                = string
    instance_class            = string
    iops                      = optional(number)
    maintenance_window        = optional(string)
    network_type              = optional(string)
    password                  = string
    port                      = optional(number)
    publicly_accessible       = optional(bool)
    skip_final_snapshot       = optional(bool)
    storage_type              = optional(string)
    username                  = string
    vpc_security_group_ids    = optional(list(string))
  })

  validation {
    condition     = length(var.aws_db_instance_primary.db_name) <= 8
    error_message = "DBName can only be 8 charachters in length."
  }
  validation {
    condition     = can(regex("^custom-oracle", var.aws_db_instance_primary.engine))
    error_message = "Engine must start with `custom-oracle*`."
  }
}

#-------------------------------
# RDS Instance Primary
#-------------------------------
variable "aws_db_instance_replicas" {
  description = <<-EOF
  Replica instance(s) configuration values. Map where the key is the argument. For examples, see /examples/ folder.
  
  Replicas will be placed in subnets separate from the primary by default.
  If specifified, availability_zones will be applied in order to the replicas. If the number of availability_zones is less than the number of replicas, the availability_zones will be applied in order until the last availability_zone is reached.
  if specified, identifiers will be applied in order to the replicas. If the number of identifiers is less than the number of replicas, the identifiers will be applied in order until the last identifier is reached, and then default indentifiers will be applied.
  
  /*
  aws_db_instance_primary = {
    replica_count      = 2
    availability_zones = ["us-east-1a", "us-east-1b"]
    identifiers        = ["replica-01", "replica-03"]
    replicate_source_db = "instance-01"
    ...
  }
  */
EOF

  type = object({
    replica_count             = number
    allocated_storage         = optional(number)
    apply_immediately         = optional(bool)
    availability_zones        = optional(list(string))
    backup_retention_period   = optional(number)
    backup_window             = optional(string)
    copy_tags_to_snapshot     = optional(bool)
    delete_automated_backups  = optional(bool)
    final_snapshot_identifier = optional(string)
    identifiers               = optional(list(string))
    instance_class            = string
    iops                      = optional(number)
    maintenance_window        = optional(string)
    network_type              = optional(string)
    port                      = optional(number)
    replicate_source_db       = optional(number)
    publicly_accessible       = optional(bool)
    skip_final_snapshot       = optional(bool)
    storage_type              = optional(string)
    vpc_security_group_ids    = optional(list(string))
  })

  default = {
    replica_count  = 0
    instance_class = ""
  }
}


variable "timeout" {
  description = <<-EOF
  Optional nested block of timeout values. For examples, see /examples/ folder.
  /*
  timeout = {
    create = "4h"
    delete = "4h"
    update = "4h"
  }
  */
EOF
  type        = any
  default     = {}
}

#-------------------------------
# Tags
#-------------------------------
variable "tags" {
  description = "Additional tags (e.g. `map('example-inc:cost-allocation:CostCenter','XYZ'`)."
  type        = map(string)
  default     = {}
}
