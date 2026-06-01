
########################
# Public Network ACLs
########################
resource "aws_network_acl" "public" {
  count = var.create_vpc && var.public_dedicated_network_acl && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id     = element(concat(aws_vpc.this.*.id, [""]), 0)
  subnet_ids = aws_subnet.public.*.id

  tags = merge(
    {
      "Name" = format("%s-${var.public_subnet_suffix}-%s", var.name,"nacl")
    },
    var.tags,
    var.public_acl_tags,
  )
}

resource "aws_network_acl_rule" "public_inbound" {
  count = var.create_vpc && var.public_dedicated_network_acl && length(var.public_subnets) > 0 ? length(var.public_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.public[0].id

  egress          = false
  rule_number     = var.public_inbound_acl_rules[count.index]["rule_no"]
  rule_action     = var.public_inbound_acl_rules[count.index]["action"]
  from_port       = lookup(var.public_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.public_inbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.public_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.public_inbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.public_inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.public_inbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.public_inbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "public_outbound" {
  count = var.create_vpc && var.public_dedicated_network_acl && length(var.public_subnets) > 0 ? length(var.public_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.public[0].id

  egress          = true
  rule_number     = var.public_outbound_acl_rules[count.index]["rule_no"]
  rule_action     = var.public_outbound_acl_rules[count.index]["action"]
  from_port       = lookup(var.public_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.public_outbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.public_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.public_outbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.public_outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.public_outbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.public_outbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

#######################
# Private Network ACLs
#######################
resource "aws_network_acl" "private" {
  count = var.create_vpc && var.private_dedicated_network_acl && length(var.private_subnets) > 0 ? 1 : 0

  vpc_id     = element(concat(aws_vpc.this.*.id, [""]), 0)
  subnet_ids = aws_subnet.private.*.id

  tags = merge(
    {
      "Name" = format("%s-${var.private_subnet_suffix}-%s", var.name,"nacl")
    },
    var.tags,
    var.private_acl_tags,
  )
}

resource "aws_network_acl_rule" "private_inbound" {
  count = var.create_vpc && var.private_dedicated_network_acl && length(var.private_subnets) > 0 ? length(var.private_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.private[0].id

  egress          = false
  rule_number     = var.private_inbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.private_inbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.private_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.private_inbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.private_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.private_inbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.private_inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.private_inbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.private_inbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "private_outbound" {
  count = var.create_vpc && var.private_dedicated_network_acl && length(var.private_subnets) > 0 ? length(var.private_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.private[0].id

  egress          = true
  rule_number     = var.private_outbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.private_outbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.private_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.private_outbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.private_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.private_outbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.private_outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.private_outbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.private_outbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

########################
# protected Network ACLs
########################
resource "aws_network_acl" "protected" {
  count = var.create_vpc && var.protected_dedicated_network_acl && length(var.protected_subnets) > 0 ? 1 : 0

  vpc_id     = element(concat(aws_vpc.this.*.id, [""]), 0)
  subnet_ids = aws_subnet.protected.*.id

  tags = merge(
    {
      "Name" = format("%s-${var.protected_subnet_suffix}-%s", var.name,"nacl")
    },
    var.tags,
    var.protected_acl_tags,
  )
}

resource "aws_network_acl_rule" "protected_inbound" {
  count = var.create_vpc && var.protected_dedicated_network_acl && length(var.protected_subnets) > 0 ? length(var.protected_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.protected[0].id

  egress          = false
  rule_number     = var.protected_inbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.protected_inbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.protected_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.protected_inbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.protected_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.protected_inbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.protected_inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.protected_inbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.protected_inbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "protected_outbound" {
  count = var.create_vpc && var.protected_dedicated_network_acl && length(var.protected_subnets) > 0 ? length(var.protected_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.protected[0].id

  egress          = true
  rule_number     = var.protected_outbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.protected_outbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.protected_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.protected_outbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.protected_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.protected_outbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.protected_outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.protected_outbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.protected_outbound_acl_rules[count.index], "ipv6_cidr_block", null)
}
