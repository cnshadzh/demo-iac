#################################
# Security group
#################################
resource "aws_security_group" "this" {
  count = var.create_security_group ? 1 : 0

  name                   = var.name
  description            = var.description
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = var.revoke_rules_on_delete

  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.name)
    },
  )
}

###################################
# Ingress rules
###################################
# Security group rules with "cidr_blocks" and it uses list of rules names
resource "aws_security_group_rule" "ingress_rules" {
  count = var.create_security_group ? length(var.ingress_rules) : 0

  security_group_id = aws_security_group.this[0].id
  type              = "ingress"

  cidr_blocks      = var.ingress_cidr_blocks
  ipv6_cidr_blocks = var.ingress_ipv6_cidr_blocks
  prefix_list_ids  = var.ingress_prefix_list_ids
  description      = var.rules[var.ingress_rules[count.index]][3]

  from_port = var.rules[var.ingress_rules[count.index]][0]
  to_port   = var.rules[var.ingress_rules[count.index]][1]
  protocol  = var.rules[var.ingress_rules[count.index]][2]
}

##################################
# Egress rules
##################################
# Security group rules with "cidr_blocks" and it uses list of rules names
resource "aws_security_group_rule" "egress_rules" {
  count = var.create_security_group ? length(var.egress_rules) : 0

  security_group_id = aws_security_group.this[0].id
  type              = "egress"

  cidr_blocks      = var.egress_cidr_blocks
  ipv6_cidr_blocks = var.egress_ipv6_cidr_blocks
  prefix_list_ids  = var.egress_prefix_list_ids
  description      = var.rules[var.egress_rules[count.index]][3]

  from_port = var.rules[var.egress_rules[count.index]][0]
  to_port   = var.rules[var.egress_rules[count.index]][1]
  protocol  = var.rules[var.egress_rules[count.index]][2]
}