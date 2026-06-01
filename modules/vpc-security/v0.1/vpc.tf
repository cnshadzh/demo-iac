#######################
# define local variables
#######################

locals {
  short_azs =["1a","1b","1c"]
}

######
# VPC
######
resource "aws_vpc" "this" {
  cidr_block                       = var.cidr
  enable_dns_hostnames             = true
  enable_dns_support               = true

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags
  )
  lifecycle {
    prevent_destroy = true
  }
}

### Remove default security group rules in new create vpc
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id
}


####################
# Internet Gateway
####################

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = format("%s-%s", var.name,"igw")
    },
    var.tags
  )
  lifecycle {
    prevent_destroy = true
  }
}





################
# mgmt subnet
################
resource "aws_subnet" "mgmt" {
  count = length(var.mgmt_subnets)

  vpc_id                          = aws_vpc.this.id
  cidr_block                      = element(var.mgmt_subnets, count.index)
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  map_public_ip_on_launch         = false
  tags = merge(
    {
      "Name" = format("%s-mgmt-%s-%s", var.name,"subnet",element(local.short_azs, count.index))
    },
    var.tags
  )
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route_table" "mgmt" {
  count = length(var.mgmt_subnets)

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = format("%s-mgmt-%s-%s", var.name,"route-table",element(local.short_azs, count.index))
    },
    var.tags
  )
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route_table_association" "mgmt" {
  count = length(var.mgmt_subnets)

  subnet_id = element(aws_subnet.mgmt.*.id, count.index)
  route_table_id = element(
    aws_route_table.mgmt.*.id,count.index,
  )
  lifecycle {
    prevent_destroy = true
  }
}


resource "aws_route" "mgmt_tgw_gateway" {
  count = length(var.mgmt_subnets)

  route_table_id         = element(aws_route_table.mgmt.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.tgw_id

  timeouts {
    create = "5m"
  }
  lifecycle {
    prevent_destroy = true
  }
}

################
# internal subnet
################
resource "aws_subnet" "internal" {
  count = length(var.internal_subnets)

  vpc_id                          = aws_vpc.this.id
  cidr_block                      = element(var.internal_subnets, count.index)
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  map_public_ip_on_launch         = false
  tags = merge(
    {
      "Name" = format("%s-internal-%s-%s", var.name,"subnet",element(local.short_azs, count.index))
    },
    var.tags
  )
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route_table" "internal" {
  count = length(var.internal_subnets)

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = format("%s-internal-%s-%s", var.name,"route-table",element(local.short_azs, count.index))
    },
    var.tags
  )
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route_table_association" "internal" {
  count = length(var.internal_subnets)

  subnet_id = element(aws_subnet.internal.*.id, count.index)
  route_table_id = element(
    aws_route_table.internal.*.id,count.index,
  )
  lifecycle {
    prevent_destroy = true
  }
}

################
# public subnet
################
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                          = aws_vpc.this.id
  cidr_block                      = element(var.public_subnets, count.index)
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  map_public_ip_on_launch         = false
  tags = merge(
    {
      "Name" = format("%s-public-%s-%s", var.name,"subnet",element(local.short_azs, count.index))
    },
    var.tags
  )
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route_table" "public" {
  count = length(var.public_subnets)

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = format("%s-public-%s-%s", var.name,"route-table",element(local.short_azs, count.index))
    },
    var.tags
  )
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(
    aws_route_table.public.*.id,count.index,
  )
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route" "public_internet_gateway" {
  count = length(var.public_subnets)

  route_table_id         = element(aws_route_table.public.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id

  timeouts {
    create = "5m"
  }
  lifecycle {
    prevent_destroy = true
  }
}

################
# tgw subnet
################
resource "aws_subnet" "tgw" {
  count = length(var.tgw_subnets)

  vpc_id                          = aws_vpc.this.id
  cidr_block                      = element(var.tgw_subnets, count.index)
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  map_public_ip_on_launch         = false
  tags = merge(
    {
      "Name" = format("%s-tgw-%s-%s", var.name,"subnet",element(local.short_azs, count.index))
    },
    var.tags
  )
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route_table" "tgw" {
  count = length(var.tgw_subnets)

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = format("%s-tgw-%s-%s", var.name,"route-table",element(local.short_azs, count.index))
    },
    var.tags
  )
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route_table_association" "tgw" {
  count = length(var.tgw_subnets)

  subnet_id = element(aws_subnet.tgw.*.id, count.index)
  route_table_id = element(
    aws_route_table.tgw.*.id,count.index,
  )
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route" "tgw_gwlbe" {
  count = length(var.tgw_subnets)

  route_table_id         = element(aws_route_table.tgw.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id      = var.gwlbe_id[count.index]

  timeouts {
    create = "5m"
  }
  lifecycle {
    prevent_destroy = true
  }
}

################
# gwlbe subnet
################
resource "aws_subnet" "gwlbe" {
  count = length(var.gwlbe_subnets)

  vpc_id                          = aws_vpc.this.id
  cidr_block                      = element(var.gwlbe_subnets, count.index)
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  map_public_ip_on_launch         = false
  tags = merge(
    {
      "Name" = format("%s-gwlbe-%s-%s", var.name,"subnet",element(local.short_azs, count.index))
    },
    var.tags
  )
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route_table" "gwlbe" {
  count = length(var.gwlbe_subnets)

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = format("%s-gwlbe-%s-%s", var.name,"route-table",element(local.short_azs, count.index))
    },
    var.tags
  )
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route_table_association" "gwlbe" {
  count = length(var.gwlbe_subnets)

  subnet_id = element(aws_subnet.gwlbe.*.id, count.index)
  route_table_id = element(
    aws_route_table.gwlbe.*.id,count.index,
  )
  lifecycle {
    prevent_destroy = true
  }
}


resource "aws_route" "gwlbe_tgw_a" {
  count = length(var.gwlbe_subnets)

  route_table_id         = element(aws_route_table.gwlbe.*.id, count.index)
  destination_cidr_block = var.tgw_cidr[0]
  transit_gateway_id     = var.tgw_id

  timeouts {
    create = "5m"
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route" "gwlbe_tgw_b" {
  count = length(var.gwlbe_subnets)

  route_table_id         = element(aws_route_table.gwlbe.*.id, count.index)
  destination_cidr_block = var.tgw_cidr[1]
  transit_gateway_id     = var.tgw_id

  timeouts {
    create = "5m"
  }
  lifecycle {
    prevent_destroy = true
  }
}

################
# gwlb subnet
################
resource "aws_subnet" "gwlb" {
  count = length(var.gwlb_subnets)

  vpc_id                          = aws_vpc.this.id
  cidr_block                      = element(var.gwlb_subnets, count.index)
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  map_public_ip_on_launch         = false
  tags = merge(
    {
      "Name" = format("%s-gwlb-%s-%s", var.name,"subnet",element(local.short_azs, count.index))
    },
    var.tags
  )
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route_table" "gwlb" {
  count = length(var.gwlb_subnets)

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = format("%s-gwlb-%s-%s", var.name,"route-table",element(local.short_azs, count.index))
    },
    var.tags
  )
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route_table_association" "gwlb" {
  count = length(var.gwlb_subnets)

  subnet_id = element(aws_subnet.gwlb.*.id, count.index)
  route_table_id = element(
    aws_route_table.gwlb.*.id,count.index,
  )
  lifecycle {
    prevent_destroy = true
  }
}

################
# dx subnet
################
resource "aws_subnet" "dx" {
  count = length(var.dx_subnets)

  vpc_id                          = aws_vpc.this.id
  cidr_block                      = element(var.dx_subnets, count.index)
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  map_public_ip_on_launch         = false
  tags = merge(
    {
      "Name" = format("%s-dx-%s-%s", var.name,"subnet",element(local.short_azs, count.index))
    },
    var.tags
  )
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route_table" "dx" {
  count = length(var.dx_subnets)

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = format("%s-dx-%s-%s", var.name,"route-table",element(local.short_azs, count.index))
    },
    var.tags
  )
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route_table_association" "dx" {
  count = length(var.dx_subnets)

  subnet_id = element(aws_subnet.dx.*.id, count.index)
  route_table_id = element(
    aws_route_table.dx.*.id,count.index,
  )
  lifecycle {
    prevent_destroy = true
  }
}

################
# tgw attachment, route table, association
################

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  transit_gateway_id = var.tgw_id
  vpc_id             = aws_vpc.this.id
  subnet_ids         = aws_subnet.tgw.*.id

  dns_support                                     = "enable"
  ipv6_support                                    = "disable"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge(
    {
      Name = "security-vpc"
    },
    var.tags
  )
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_ec2_transit_gateway_route_table" "this" {
  transit_gateway_id = var.tgw_id

  tags = merge(
    {
      "Name" = format("%s", var.tgw_route_table_name)
    },
    var.tags
  )
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "this" {

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
  lifecycle {
    prevent_destroy = true
  }
}

