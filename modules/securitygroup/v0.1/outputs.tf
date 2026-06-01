output "this_security_group_id" {
  description = "The ID of the security group"
  value =  var.create_security_group ? aws_security_group.this[0].id : null
}