output "vpc_id" {
    value = aws_vpc.this.id
}

output "igw_id" {
    value = aws_internet_gateway.this.id
}

output "mgmt_subnets" {
    value = aws_subnet.mgmt.*.id
}

output "gwlb_subnets" {
    value = aws_subnet.gwlb.*.id
}

output "gwlbe_subnets" {
    value = aws_subnet.gwlbe.*.id
}