data "aws_region" "current" {}

#-------------------------------
# EC2
#-------------------------------
data "aws_vpc_endpoint_service" "ec2" {
  service = "ec2"
}

data "aws_subnets" "ec2" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "subnet-id"
    values = var.private_subnet_ids
  }

  filter {
    name   = "availability-zone"
    values = data.aws_vpc_endpoint_service.ec2.availability_zones
  }
}

#-------------------------------
# EC2 Messages
#-------------------------------
data "aws_vpc_endpoint_service" "ec2messages" {
  service = "ec2messages"
}

data "aws_subnets" "ec2messages" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "subnet-id"
    values = var.private_subnet_ids
  }

  filter {
    name   = "availability-zone"
    values = data.aws_vpc_endpoint_service.ec2messages.availability_zones
  }
}

#-------------------------------
# Monitoring
#-------------------------------
data "aws_vpc_endpoint_service" "monitoring" {
  service = "monitoring"
}

data "aws_subnets" "monitoring" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "subnet-id"
    values = var.private_subnet_ids
  }

  filter {
    name   = "availability-zone"
    values = data.aws_vpc_endpoint_service.monitoring.availability_zones
  }
}

#-------------------------------
# SSM
#-------------------------------
data "aws_vpc_endpoint_service" "ssm" {
  service = "ssm"
}

data "aws_subnets" "ssm" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "subnet-id"
    values = var.private_subnet_ids
  }

  filter {
    name   = "availability-zone"
    values = data.aws_vpc_endpoint_service.ssm.availability_zones
  }
}


#-------------------------------
# SSM Messages
#-------------------------------
data "aws_vpc_endpoint_service" "ssmmessages" {
  service = "ssmmessages"
}

data "aws_subnets" "ssmmessages" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "subnet-id"
    values = var.private_subnet_ids
  }

  filter {
    name   = "availability-zone"
    values = data.aws_vpc_endpoint_service.ssmmessages.availability_zones
  }
}


#-------------------------------
# Logs
#-------------------------------
data "aws_vpc_endpoint_service" "logs" {
  service = "logs"
}

data "aws_subnets" "logs" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "subnet-id"
    values = var.private_subnet_ids
  }

  filter {
    name   = "availability-zone"
    values = data.aws_vpc_endpoint_service.logs.availability_zones
  }
}


#-------------------------------
# Events
#-------------------------------
data "aws_vpc_endpoint_service" "events" {
  service = "events"
}

data "aws_subnets" "events" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "subnet-id"
    values = var.private_subnet_ids
  }

  filter {
    name   = "availability-zone"
    values = data.aws_vpc_endpoint_service.events.availability_zones
  }
}


#-------------------------------
# Secrets Manager
#-------------------------------
data "aws_vpc_endpoint_service" "secretsmanager" {
  service = "secretsmanager"
}

data "aws_subnets" "secretsmanager" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "subnet-id"
    values = var.private_subnet_ids
  }

  filter {
    name   = "availability-zone"
    values = data.aws_vpc_endpoint_service.secretsmanager.availability_zones
  }
}
