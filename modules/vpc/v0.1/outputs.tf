output "public_subnets" {
    value = aws_subnet.public.*.id
}

output "private_subnets" {
    value = aws_subnet.private.*.id
}

output "protected_subnets" {
    value = aws_subnet.protected.*.id
}

output "vpc_id" {
    value = aws_vpc.this[0].id
}

output "private_route_table_ids" {
    value = aws_route_table.private.*.id
}

output "public_route_table_ids" {
    value = aws_route_table.public.*.id
}

output "protected_route_table_ids" {
    value = aws_route_table.protected.*.id
}

output "igw_id" {
    value = aws_internet_gateway.this[0].id
}

