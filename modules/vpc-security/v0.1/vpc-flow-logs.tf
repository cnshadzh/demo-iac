
### VPC flow logs enable for new create VPC
resource "aws_flow_log" "this" {
  log_destination      = var.vpc_flow_logs_destination
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.this.id
  max_aggregation_interval = var.flow_log_max_aggregation_interval
}
