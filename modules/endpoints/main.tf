#-------------------------------
# VPC Endpoint Security Group
#-------------------------------

resource "aws_security_group" "vpc_endpoint_sg" {
  count = var.create_endpoint_security_group ? 1 : 0

  name        = var.endpoint_security_group_name != null ? var.endpoint_security_group_name : null
  name_prefix = var.endpoint_security_group_name != null ? null : "awsrdscustom_"
  description = var.endpoint_security_group_description
  tags        = var.tags
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "inbound_tls" {
  count = var.create_endpoint_security_group ? 1 : 0

  description       = "Allow inbound TLS"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.vpc_endpoint_sg[0].id
}

resource "aws_security_group_rule" "inbound_http" {
  count = var.create_endpoint_security_group ? 1 : 0

  description       = "Allow inbound HTTP"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.vpc_endpoint_sg[0].id
}

resource "aws_security_group_rule" "outbound_all" {
  count = var.create_endpoint_security_group ? 1 : 0

  description       = "Allow outbound traffic to internet"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.vpc_cidr] #tfsec:ignore:aws-ec2-no-public-egress-sgr
  security_group_id = aws_security_group.vpc_endpoint_sg[0].id
}

#-------------------------------
# VPC Gateway Endpoints
#-------------------------------

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  route_table_ids   = var.private_subnet_route_table_ids
  tags              = var.tags
}

#-------------------------------
# VPC Interface Endpoints
#-------------------------------

resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = var.vpc_id
  service_name      = data.aws_vpc_endpoint_service.ec2.service_name
  vpc_endpoint_type = "Interface"
  subnet_ids        = data.aws_subnets.ec2.ids
  security_group_ids = [
    local.sg_id
  ]

  private_dns_enabled = true
  tags                = var.tags
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = var.vpc_id
  service_name      = data.aws_vpc_endpoint_service.ec2messages.service_name
  vpc_endpoint_type = "Interface"
  subnet_ids        = data.aws_subnets.ec2messages.ids
  security_group_ids = [
    local.sg_id
  ]

  private_dns_enabled = true
  tags                = var.tags
}

resource "aws_vpc_endpoint" "monitoring" {
  vpc_id            = var.vpc_id
  service_name      = data.aws_vpc_endpoint_service.monitoring.service_name
  vpc_endpoint_type = "Interface"
  subnet_ids        = data.aws_subnets.monitoring.ids
  security_group_ids = [
    local.sg_id
  ]

  private_dns_enabled = true
  tags                = var.tags
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = var.vpc_id
  service_name      = data.aws_vpc_endpoint_service.ssm.service_name
  vpc_endpoint_type = "Interface"
  subnet_ids        = data.aws_subnets.ssm.ids
  security_group_ids = [
    local.sg_id
  ]

  private_dns_enabled = true
  tags                = var.tags
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = var.vpc_id
  service_name      = data.aws_vpc_endpoint_service.ssmmessages.service_name
  vpc_endpoint_type = "Interface"
  subnet_ids        = data.aws_subnets.ssmmessages.ids
  security_group_ids = [
    local.sg_id
  ]

  private_dns_enabled = true
  tags                = var.tags
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id            = var.vpc_id
  service_name      = data.aws_vpc_endpoint_service.logs.service_name
  vpc_endpoint_type = "Interface"
  subnet_ids        = data.aws_subnets.logs.ids
  security_group_ids = [
    local.sg_id
  ]

  private_dns_enabled = true
  tags                = var.tags
}

resource "aws_vpc_endpoint" "events" {
  vpc_id            = var.vpc_id
  service_name      = data.aws_vpc_endpoint_service.events.service_name
  vpc_endpoint_type = "Interface"
  subnet_ids        = data.aws_subnets.events.ids
  security_group_ids = [
    local.sg_id
  ]

  private_dns_enabled = true
  tags                = var.tags
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id            = var.vpc_id
  service_name      = data.aws_vpc_endpoint_service.secretsmanager.service_name
  vpc_endpoint_type = "Interface"
  subnet_ids        = data.aws_subnets.secretsmanager.ids
  security_group_ids = [
    local.sg_id
  ]

  private_dns_enabled = true
  tags                = var.tags
}

