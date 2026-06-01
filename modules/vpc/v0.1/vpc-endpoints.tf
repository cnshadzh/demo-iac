#######################
# VPC Endpoint for SSM
#######################
data "aws_vpc_endpoint_service" "ssm" {
  count = var.create_vpc && var.enable_ssm_endpoint ? 1 : 0

  service = "ssm"
}

resource "aws_vpc_endpoint" "ssm" {
  count = var.create_vpc && var.enable_ssm_endpoint ? 1 : 0

  vpc_id            = aws_vpc.this[0].id
  service_name      = data.aws_vpc_endpoint_service.ssm[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.endpoints_security_group_ids
  subnet_ids          = coalescelist(var.ssm_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.ssm_endpoint_private_dns_enabled
  tags = {
    Name = format("%s-%s", var.name,"ssm")
  }
}

###############################
# VPC Endpoint for SSMMESSAGES
###############################
data "aws_vpc_endpoint_service" "ssmmessages" {
  count = var.create_vpc && var.enable_ssmmessages_endpoint ? 1 : 0

  service = "ssmmessages"
}

resource "aws_vpc_endpoint" "ssmmessages" {
  count = var.create_vpc && var.enable_ssmmessages_endpoint ? 1 : 0

  vpc_id            = aws_vpc.this[0].id
  service_name      = data.aws_vpc_endpoint_service.ssmmessages[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.endpoints_security_group_ids
  subnet_ids          = coalescelist(var.ssmmessages_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.ssmmessages_endpoint_private_dns_enabled
  tags = {
    Name = format("%s-%s", var.name,"ssmmessages")
  }
}

###############################
# VPC Endpoint for EC2MESSAGES
###############################
data "aws_vpc_endpoint_service" "ec2messages" {
  count = var.create_vpc && var.enable_ec2messages_endpoint ? 1 : 0

  service = "ec2messages"
}

resource "aws_vpc_endpoint" "ec2messages" {
  count = var.create_vpc && var.enable_ec2messages_endpoint ? 1 : 0

  vpc_id            = aws_vpc.this[0].id
  service_name      = data.aws_vpc_endpoint_service.ec2messages[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.endpoints_security_group_ids
  subnet_ids          = coalescelist(var.ec2messages_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.ec2messages_endpoint_private_dns_enabled
  tags = {
    Name = format("%s-%s", var.name,"ec2messages")
  }
}
