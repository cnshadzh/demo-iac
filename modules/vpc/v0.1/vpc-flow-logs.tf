
### VPC flow logs enable for new create VPC
resource "aws_flow_log" "this" {
  count = var.create_vpc && var.enable_flow_logs ? 1:0
  log_destination      = var.vpc_flow_logs_destination
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.this[0].id
  max_aggregation_interval = var.flow_log_max_aggregation_interval
}

### VPC flow logs enable for default VPC to meet the security requirement.

// resource "aws_flow_log" "default_vpc" {
//   count = var.enable_flow_logs ? 1:0
//   log_destination      = var.vpc_flow_logs_destination
//   log_destination_type = "s3"
//   traffic_type         = "ALL"
//   vpc_id               = aws_default_vpc.default.id
//   max_aggregation_interval = var.flow_log_max_aggregation_interval
// }