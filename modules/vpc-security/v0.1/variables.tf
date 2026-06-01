variable "vpc_flow_logs_destination" {
  description = "The destination for the vpc flow logs"
  type        = string
  default = ""
}


variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}


variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
}

variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
}


variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_tags" {
  description = "Additional tags for the VPC"
  type        = map(string)
  default     = {}
}



variable "flow_log_max_aggregation_interval" {
  description = "The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60` seconds or `600` seconds."
  type        = number
  default     = 600
}



variable "mgmt_subnets" {
  description = "A list of mgmt subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "internal_subnets" {
  description = "A list of internal subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "tgw_subnets" {
  description = "A list of tgw subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "gwlbe_subnets" {
  description = "A list of gwlb endpoint subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "gwlb_subnets" {
  description = "A list of gwlb subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "dx_subnets" {
  description = "A list of dx subnets inside the VPC"
  type        = list(string)
  default     = []
}
variable "tgw_id" {
  description = "tgw id"
  type        = string
  default     = null
}

variable "tgw_route_table_name" {
  description = "Name to be used on all tgw_route_table"
  type        = string
  default     = ""
}

variable "tgw_cidr" {
  description = "cidr to route to tgw"
  type        = list(string)
  default     = []
}

variable "gwlbe_id" {
  description = "A list of gwlbe ids"
  type        = list(string)
  default     = []
}
