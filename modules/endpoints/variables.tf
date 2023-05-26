#-------------------------------
# VPC Config for RDS Instance
#-------------------------------
variable "vpc_id" {
  description = "VPC Id for the endpoints."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR for the endpoints to communicate with."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnets Ids in which to create endpoint network interfaces."
  type        = list(string)
  default     = []
}

variable "private_subnet_route_table_ids" {
  description = "List of private subnets route tables in which to associate the gateway endpoints."
  type        = list(string)
  default     = []
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
  description = "Name to use on endpoint security group created."
  type        = string
  default     = null
}

variable "endpoint_security_group_description" {
  description = "Description of the endpoint security group created."
  type        = string
  default     = "Endpoint security group"
}

variable "endpoint_security_group_id" {
  description = "Security group to be used if creation of endpoint security group is turned off."
  type        = string
  default     = ""
}

#-------------------------------
# Tags
#-------------------------------
variable "tags" {
  description = "Additional tags (e.g. `map('example-inc:cost-allocation:CostCenter','XYZ'`)."
  type        = map(string)
  default     = {}
}