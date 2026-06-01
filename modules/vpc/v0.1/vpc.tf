#######################
# define local variables
#######################

locals {
  nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(var.azs) : length(var.private_subnets)

  # Use `local.vpc_id` to give a hint to Terraform that subnets should be deleted before secondary CIDR blocks can be free!
  vpc_id = element(
    concat(
      aws_vpc.this.*.id,
      [""],
    ),
    0,
  )

  short_azs =["1a","1b","1c"]

  vpce_tags = merge(
    var.tags,
    var.vpc_endpoint_tags,
  )
}

######
# VPC
######
resource "aws_vpc" "this" {
  count = var.create_vpc ? 1 : 0

  cidr_block                       = var.cidr
  instance_tenancy                 = var.instance_tenancy
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  assign_generated_ipv6_cidr_block = var.enable_ipv6

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags,
    var.vpc_tags,
  )
  lifecycle {
    prevent_destroy = true
  }
}

### Remove default security group rules in new create vpc
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this[0].id
}

### Remove default security group rules in default vpc

resource "aws_default_vpc" "default" {}

resource "aws_default_security_group" "default-vpc" {
  vpc_id = aws_default_vpc.default.id
}

####################
# Internet Gateway
####################

resource "aws_internet_gateway" "this" {
  count = var.create_vpc && var.create_igw && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      "Name" = format("%s-%s", var.name,"igw")
    },
    var.tags,
    var.igw_tags,
  )
  lifecycle {
    prevent_destroy = true
  }
}


################
# Public subnet
################
resource "aws_subnet" "public" {
  count = var.create_vpc && length(var.public_subnets) > 0 && (false == var.one_nat_gateway_per_az || length(var.public_subnets) >= length(var.azs)) ? length(var.public_subnets) : 0

  vpc_id                          = aws_vpc.this[0].id
  cidr_block                      = element(concat(var.public_subnets, [""]), count.index)
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id            = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
  map_public_ip_on_launch         = var.map_public_ip_on_launch

  tags = merge(
    {
      "Name" = format("%s-%s-${var.public_subnet_suffix}-%s-%s", var.name, var.environment, "subnet",element(local.short_azs, count.index))
    },
    var.tags,
    var.public_subnet_tags,
  )
  lifecycle {
    prevent_destroy = true
  }
}

#################
# Private subnet
#################
resource "aws_subnet" "private" {
  count = var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  vpc_id                          = aws_vpc.this[0].id
  cidr_block                      = var.private_subnets[count.index]
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id            = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
  tags = merge(
    {
      "Name" = format("%s-%s-${var.private_subnet_suffix}-%s-%s", var.name, var.environment, "subnet",element(local.short_azs, count.index))
    },
    var.tags,
    var.private_subnet_tags,
  )
  lifecycle {
    prevent_destroy = true
  }
}

##################
# Protected subnet
##################
resource "aws_subnet" "protected" {
  count = var.create_vpc && length(var.protected_subnets) > 0 ? length(var.protected_subnets) : 0

  vpc_id                          = aws_vpc.this[0].id
  cidr_block                      = var.protected_subnets[count.index]
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id            = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
  tags = merge(
    {
      "Name" = format("%s-%s-${var.protected_subnet_suffix}-%s-%s", var.name, var.environment, "subnet",element(local.short_azs, count.index))
    },
    var.tags,
    var.protected_subnet_tags,
  )
  lifecycle {
    prevent_destroy = true
  }
}

################
# Publiс routes
################
resource "aws_route_table" "public" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      "Name" = format("%s-%s-${var.public_subnet_suffix}-%s-%s", var.name, var.environment, "route-table",element(local.short_azs, count.index))
    },
    var.tags,
    var.public_route_table_tags,
  )
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route" "public_internet_gateway" {
  count = var.create_vpc && var.create_igw && length(var.public_subnets) > 0 ? length(var.public_subnets): 0

  route_table_id         = element(aws_route_table.public.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  timeouts {
    create = "5m"
  }
  lifecycle {
    prevent_destroy = true
  }
}

#################
# Private routes
# There are as many routing tables as the number of NAT gateways
#################
resource "aws_route_table" "private" {
  count = var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      "Name" = format("%s-%s-${var.private_subnet_suffix}-%s-%s", var.name, var.environment, "route-table",element(local.short_azs, count.index))
    },
    var.tags,
    var.private_route_table_tags,
  )
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route_table" "protected" {
  count = var.create_vpc && length(var.protected_subnets) > 0 ? length(var.protected_subnets) : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      "Name" = format("%s-%s-${var.protected_subnet_suffix}-%s-%s", var.name, var.environment, "route-table",element(local.short_azs, count.index))
    },
    var.tags,
    var.protected_route_table_tags,
  )
  lifecycle {
    prevent_destroy = true
  }
}


##############
# NAT Gateway
##############

locals {
  nat_gateway_ips = split(
    ",",
    var.reuse_nat_ips ? join(",", var.external_nat_ip_ids) : join(",", aws_eip.nat.*.id),
  )
}

resource "aws_eip" "nat" {
  count = var.create_vpc && var.enable_nat_gateway && false == var.reuse_nat_ips ? local.nat_gateway_count : 0

  domain = "vpc"

  tags = merge(
    {
      "Name" = format(
        "%s-%s-%s",
        var.name,
        "eip",
        element(local.short_azs, var.single_nat_gateway ? 0 : count.index),
      )
    },
    var.tags,
    var.nat_eip_tags,
  )
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_nat_gateway" "this" {
  count = var.create_vpc && var.enable_nat_gateway ? local.nat_gateway_count : 0

  allocation_id = element(
    local.nat_gateway_ips,
    var.single_nat_gateway ? 0 : count.index,
  )
  subnet_id = element(
    aws_subnet.public.*.id,
    var.single_nat_gateway ? 0 : count.index,
  )

  tags = merge(
    {
      "Name" = format(
        "%s-%s-%s",
        var.name,
        "natgateway",
        element(local.short_azs, var.single_nat_gateway ? 0 : count.index),
      )
    },
    var.tags,
    var.nat_gateway_tags,
  )

  depends_on = [aws_internet_gateway.this]
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route" "private_nat_gateway" {
  count = var.create_vpc && var.enable_nat_gateway && var.enable_nat_route ? length(var.private_subnets) : 0

  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this.*.id, count.index)

  timeouts {
    create = "5m"
  }
  lifecycle {
    prevent_destroy = true
  }
}

##########################
# Route table association
##########################
resource "aws_route_table_association" "private" {
  count = var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  subnet_id = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(
    aws_route_table.private.*.id,count.index,
  )
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route_table_association" "public" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(
    aws_route_table.public.*.id, count.index)
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route_table_association" "protected" {
  count = var.create_vpc && length(var.protected_subnets) > 0 ? length(var.protected_subnets) : 0

  subnet_id      = element(aws_subnet.protected.*.id, count.index)
  route_table_id = element(
    aws_route_table.protected.*.id, count.index)
  lifecycle {
    prevent_destroy = true
  }
}
