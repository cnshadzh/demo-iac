variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the project."
}

variable "region" {
  description = "The application's account region"
  default     = ""
  type        = string
}

variable "cross_account_role_arn" {
  description = "Cross account admin role arn"
  default     = ""
  type        = string
}

variable "actions_alarm" {
  type        = list(any)
  default     = []
  description = "A list of actions to take when alarms are triggered. Will likely be an SNS topic for event distribution."
}


variable "use_existing_security_groups" {
  type        = bool
  description = "Flag to enable/disable creation of Security Group in the module. Set to `true` to disable Security Group creation and provide a list of existing security Group IDs in `existing_security_groups` to place the cluster into"
  default     = false
}

variable "existing_security_groups" {
  type        = list(string)
  default     = []
  description = "List of existing Security Group IDs to place the cluster into. Set `use_existing_security_groups` to `true` to enable using `existing_security_groups` as Security Groups for the cluster"
}

variable "allowed_security_groups" {
  type        = list(string)
  default     = []
  description = "List of Security Group IDs that are allowed ingress to the cluster's Security Group created in the module"
}

variable "security_group_description" {
  type        = string
  description = "The description for the security group. If this is changed, this will cause a create/destroy on the security group resource. Set this to `null` to maintain parity with releases <= `0.34.0`."
  default     = "Security group for Elasticache Redis"
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks that are allowed ingress to the cluster's Security Group created in the module"
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC ID"
}

variable "partition" {
  type        = string
  default     = ""
  description = "account partition"
}

variable "protected_subnets" {
  type        = list(string)
  description = "Subnet IDs"
  default     = []
}

variable "private_subnets" {
  type        = list(string)
  description = "Subnet IDs"
  default     = []
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Subnet IDs"
  default     = []
}

variable "elasticache_subnet_group_name" {
  type        = string
  description = "Subnet group name for the ElastiCache instance"
  default     = ""
}

variable "maintenance_window" {
  type        = string
  default     = "wed:03:00-wed:04:00"
  description = "Maintenance window"
}

variable "cluster_size" {
  type        = number
  default     = 1
  description = "Number of nodes in cluster. *Ignored when `cluster_mode_enabled` == `true`*"
}

variable "port" {
  type        = number
  default     = 6379
  description = "Redis port"
}

variable "instance_type" {
  type        = string
  default     = "cache.t2.micro"
  description = "Elastic cache instance type"
}

variable "family" {
  type        = string
  default     = "redis4.0"
  description = "Redis family"
}

variable "parameter" {
  type = list(object({
    name  = string
    value = string
  }))
  default     = []
  description = "A list of Redis parameters to apply. Note that parameters may differ from one Redis family to another"
}

variable "engine_version" {
  type        = string
  default     = "4.0.10"
  description = "Redis engine version"
}

variable "at_rest_encryption_enabled" {
  type        = bool
  default     = false
  description = "Enable encryption at rest"
}

variable "transit_encryption_enabled" {
  type        = bool
  default     = true
  description = "Whether to enable encryption in transit. If this is enabled, use the [following guide](https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/in-transit-encryption.html#connect-tls) to access redis"
}

variable "notification_topic_arn" {
  type        = string
  default     = ""
  description = "Notification topic arn"
}

variable "alarm_cpu_threshold_percent" {
  type        = number
  default     = 75
  description = "CPU threshold alarm level"
}

variable "alarm_memory_threshold_bytes" {
  # 10MB
  type        = number
  default     = 10000000
  description = "Ram threshold alarm level"
}

variable "alarm_actions" {
  type        = list(string)
  description = "Alarm action list"
  default     = []
}

variable "ok_actions" {
  type        = list(string)
  description = "The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Number (ARN)"
  default     = []
}

variable "apply_immediately" {
  type        = bool
  default     = true
  description = "Apply changes immediately"
}

variable "automatic_failover_enabled" {
  type        = bool
  default     = false
  description = "Automatic failover (Not available for T1/T2 instances)"
}

variable "multi_az_enabled" {
  type        = bool
  default     = false
  description = "Multi AZ (Automatic Failover must also be enabled.  If Cluster Mode is enabled, Multi AZ is on by default, and this setting is ignored)"
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability zone IDs"
  default     = []
}

variable "zone_id" {
  type        = string
  default     = ""
  description = "Route53 DNS Zone ID"
}

variable "dns_subdomain" {
  type        = string
  default     = ""
  description = "The subdomain to use for the CNAME record. If not provided then the CNAME record will use var.name."
}

variable "auth_token" {
  type        = string
  description = "Auth token for password protecting redis, `transit_encryption_enabled` must be set to `true`. Password must be longer than 16 chars"
  default     = null
}

variable "kms_key_id" {
  type        = string
  description = "The ARN of the key that you wish to use if encrypting at rest. If not supplied, uses service managed encryption. `at_rest_encryption_enabled` must be set to `true`"
  default     = null
}

variable "replication_group_id" {
  type        = string
  description = "Replication group ID with the following constraints: \nA name must contain from 1 to 20 alphanumeric characters or hyphens. \n The first character must be a letter. \n A name cannot end with a hyphen or contain two consecutive hyphens."
  default     = ""
}

variable "snapshot_arns" {
  type        = list(string)
  description = "A single-element string list containing an Amazon Resource Name (ARN) of a Redis RDB snapshot file stored in Amazon S3. Example: arn:aws:s3:::my_bucket/snapshot1.rdb"
  default     = []
}


variable "snapshot_name" {
  type        = string
  description = "The name of a snapshot from which to restore data into the new node group. Changing the snapshot_name forces a new resource."
  default     = null
}

variable "snapshot_window" {
  type        = string
  description = "The daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of your cache cluster."
  default     = "06:30-07:30"
}

variable "snapshot_retention_limit" {
  type        = number
  description = "The number of days for which ElastiCache will retain automatic cache cluster snapshots before deleting them."
  default     = 0
}

variable "final_snapshot_identifier" {
  type        = string
  description = "The name of your final node group (shard) snapshot. ElastiCache creates the snapshot from the primary node in the cluster. If omitted, no final snapshot will be made."
  default     = null
}

variable "cluster_mode_enabled" {
  type        = bool
  description = "Flag to enable/disable creation of a native redis cluster. `automatic_failover_enabled` must be set to `true`. Only 1 `cluster_mode` block is allowed"
  default     = false
}

variable "cluster_mode_replicas_per_node_group" {
  type        = number
  description = "Number of replica nodes in each node group. Valid values are 0 to 5. Changing this number will force a new resource"
  default     = 0
}

variable "cluster_mode_num_node_groups" {
  type        = number
  description = "Number of node groups (shards) for this Redis replication group. Changing this number will trigger an online resizing operation before other settings modifications"
  default     = 0
}

variable "cloudwatch_metric_alarms_enabled" {
  type        = bool
  description = "Boolean flag to enable/disable CloudWatch metrics alarms"
  default     = false
}

variable "egress_cidr_blocks" {
  type        = list(any)
  default     = ["0.0.0.0/0"]
  description = "Outbound traffic address"
}

# module "rds"
variable "identifier" {
  description = "The name of the RDS instance, if omitted, Terraform will assign a random, unique identifier"
  type        = string
  default     = ""
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = string
  default     = null
}

variable "storage_type" {
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD). The default is 'io1' if iops is specified, 'gp2' if not."
  type        = string
  default     = null
}

variable "storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted"
  type        = bool
  default     = false
}

variable "replicate_source_db" {
  description = "Specifies that this resource is a Replicate database, and to use this value as the source database. This correlates to the identifier of another Amazon RDS Database to replicate."
  type        = string
  default     = null
}

variable "cross_region_replica" {
  description = "Specifies if the replica should be cross region. It allows the use of a subnet group in a region different than the master instance"
  type        = bool
  default     = false
}

variable "license_model" {
  description = "License model information for this DB instance. Optional, but required for some DB engines, i.e. Oracle SE1"
  type        = string
  default     = null
}

variable "iam_database_authentication_enabled" {
  description = "Specifies whether or not the mappings of AWS Identity and Access Management (IAM) accounts to database accounts are enabled"
  type        = bool
  default     = false
}

variable "domain" {
  description = "The ID of the Directory Service Active Directory domain to create the instance in"
  type        = string
  default     = null
}

variable "domain_iam_role_name" {
  description = "(Required if domain is provided) The name of the IAM role to be used when making API calls to the Directory Service"
  type        = string
  default     = null
}

variable "engine" {
  description = "The database engine to use"
  type        = string
  default     = ""
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted. If true is specified, no DBSnapshot is created. If false is specified, a DB snapshot is created before the DB instance is deleted, using the value from final_snapshot_identifier"
  type        = bool
  default     = false
}

variable "snapshot_identifier" {
  description = "Specifies whether or not to create this database from a snapshot. This correlates to the snapshot ID you'd find in the RDS console, e.g: rds:production-2015-06-26-06-05."
  type        = string
  default     = null
}

variable "copy_tags_to_snapshot" {
  description = "On delete, copy all Instance tags to the final snapshot (if final_snapshot_identifier is specified)"
  type        = bool
  default     = false
}

variable "final_snapshot_identifier_prefix" {
  description = "The name which is prefixed to the final snapshot on cluster destroy"
  type        = string
  default     = "final"
}

variable "instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = null
}

variable "name" {
  description = "The DB name to create. If omitted, no database is created initially"
  type        = string
  default     = null
}

variable "username" {
  description = "Username for the master DB user"
  type        = string
  default     = null
}

variable "password" {
  description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file"
  type        = string
  default     = ""
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate"
  type        = list(string)
  default     = []
}

variable "availability_zone" {
  description = "The Availability Zone of the RDS instance"
  type        = string
  default     = null
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = false
}

variable "iops" {
  description = "The amount of provisioned IOPS. Setting this implies a storage_type of 'io1'"
  type        = number
  default     = 0
}

variable "publicly_accessible" {
  description = "Bool to control if instance is publicly accessible"
  type        = bool
  default     = false
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60."
  type        = number
  default     = 0
}

variable "monitoring_role_arn" {
  description = "The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. Must be specified if monitoring_interval is non-zero."
  type        = string
  default     = null
}

variable "monitoring_role_name" {
  description = "Name of the IAM role which will be created when create_monitoring_role is enabled."
  type        = string
  default     = "rds-monitoring-role"
}

variable "monitoring_role_description" {
  description = "Description of the monitoring IAM role"
  type        = string
  default     = null
}

variable "create_monitoring_role" {
  description = "Create IAM role with a defined name that permits RDS to send enhanced monitoring metrics to CloudWatch Logs."
  type        = bool
  default     = false
}

variable "allow_major_version_upgrade" {
  description = "Indicates that major version upgrades are allowed. Changing this parameter does not result in an outage and the change is asynchronously applied as soon as possible"
  type        = bool
  default     = false
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "The days to retain backups for"
  type        = number
  default     = null
}

variable "backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled. Example: '09:46-10:16'. Must not overlap with maintenance_window"
  type        = string
  default     = null
}

variable "restore_to_point_in_time" {
  description = "Restore to a point in time (MySQL is NOT supported)"
  type        = map(string)
  default     = null
}

variable "s3_import" {
  description = "Restore from a Percona Xtrabackup in S3 (only MySQL is supported)"
  type        = map(string)
  default     = null
}

variable "db_instance_tags" {
  description = "Additional tags for the DB instance"
  type        = map(string)
  default     = {}
}

variable "db_option_group_tags" {
  description = "Additional tags for the DB option group"
  type        = map(string)
  default     = {}
}

variable "db_parameter_group_tags" {
  description = "Additional tags for the  DB parameter group"
  type        = map(string)
  default     = {}
}

variable "db_subnet_group_tags" {
  description = "Additional tags for the DB subnet group"
  type        = map(string)
  default     = {}
}

# DB subnet group
variable "create_db_subnet_group" {
  description = "Whether to create a database subnet group"
  type        = bool
  default     = true
}

variable "db_subnet_group_name" {
  description = "Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group. If unspecified, will be created in the default VPC"
  type        = string
  default     = null
}

variable "db_subnet_group_use_name_prefix" {
  description = "Determines whether to use `subnet_group_name` as is or create a unique name beginning with the `subnet_group_name` as the prefix"
  type        = bool
  default     = true
}

variable "db_subnet_group_description" {
  description = "Description of the DB subnet group to create"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "A list of VPC subnet IDs"
  type        = list(string)
  default     = []
}

# DB parameter group
variable "create_db_parameter_group" {
  description = "Whether to create a database parameter group"
  type        = bool
  default     = true
}

variable "parameter_group_name" {
  description = "Name of the DB parameter group to associate or create"
  type        = string
  default     = null
}

variable "parameter_group_use_name_prefix" {
  description = "Determines whether to use `parameter_group_name` as is or create a unique name beginning with the `parameter_group_name` as the prefix"
  type        = bool
  default     = true
}

variable "parameter_group_description" {
  description = "Description of the DB parameter group to create"
  type        = string
  default     = ""
}

variable "parameters" {
  description = "A list of DB parameters (map) to apply"
  type        = list(map(string))
  default     = []
}

# DB option group
variable "create_db_option_group" {
  description = "(Optional) Create a database option group"
  type        = bool
  default     = true
}

variable "option_group_name" {
  description = "Name of the option group"
  type        = string
  default     = null
}

variable "option_group_use_name_prefix" {
  description = "Determines whether to use `option_group_name` as is or create a unique name beginning with the `option_group_name` as the prefix"
  type        = bool
  default     = true
}

variable "option_group_description" {
  description = "The description of the option group"
  type        = string
  default     = ""
}

variable "major_engine_version" {
  description = "Specifies the major version of the engine that this option group should be associated with"
  type        = string
  default     = ""
}

variable "options" {
  description = "A list of Options to apply."
  type        = any
  default     = []
}

variable "create_db_instance" {
  description = "Whether to create a database instance"
  type        = bool
  default     = true
}

variable "timezone" {
  description = "(Optional) Time zone of the DB instance. timezone is currently only supported by Microsoft SQL Server. The timezone can only be set on creation. See MSSQL User Guide for more information."
  type        = string
  default     = null
}

variable "character_set_name" {
  description = "(Optional) The character set name to use for DB encoding in Oracle instances. This can't be changed. See Oracle Character Sets Supported in Amazon RDS and Collations and Character Sets for Microsoft SQL Server for more information. This can only be set on creation."
  type        = string
  default     = null
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported. Valid values (depending on engine): alert, audit, error, general, listener, slowquery, trace, postgresql (PostgreSQL), upgrade (PostgreSQL)."
  type        = list(string)
  default     = []
}

variable "timeouts" {
  description = "(Optional) Updated Terraform resource management timeouts. Applies to `aws_db_instance` in particular to permit resource management times"
  type        = map(string)
  default = {
    create = "40m"
    update = "80m"
    delete = "40m"
  }
}

variable "option_group_timeouts" {
  description = "Define maximum timeout for deletion of `aws_db_option_group` resource"
  type        = map(string)
  default = {
    delete = "15m"
  }
}

variable "deletion_protection" {
  description = "The database can't be deleted when this value is set to true."
  type        = bool
  default     = false
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights are enabled"
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  description = "The amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years)."
  type        = number
  default     = 7
}

variable "performance_insights_kms_key_id" {
  description = "The ARN for the KMS key to encrypt Performance Insights data."
  type        = string
  default     = null
}

variable "max_allocated_storage" {
  description = "Specifies the value for Storage Autoscaling"
  type        = number
  default     = 0
}

variable "ca_cert_identifier" {
  description = "Specifies the identifier of the CA certificate for the DB instance"
  type        = string
  default     = null
}

variable "delete_automated_backups" {
  description = "Specifies whether to remove automated backups immediately after the DB instance is deleted"
  type        = bool
  default     = true
}

variable "create_random_password" {
  description = "Whether to create random password for RDS primary cluster"
  type        = bool
  default     = false
}

variable "random_password_length" {
  description = "(Optional) Length of random password to create. (default: 10)"
  type        = number
  default     = 10
}

variable "eks_name" {
  description = "eks_name"
  type        = string
  default     = ""
}

variable "product" {
  description = "product"
  type        = string
  default     = ""
}

variable "environment_name" {
  description = "environment_name"
  type        = string
  default     = ""
}

variable "rds_sg" {
  description = "RDS security group id"
  type        = string
  default     = ""
}

variable "docdb_sg" {
  description = "RDS security group id"
  type        = string
  default     = ""
}

variable "redis_sg" {
  description = "redis security group id"
  type        = string
  default     = ""
}

variable "msk_sg" {
  description = "msk security group id"
  type        = string
  default     = ""
}

variable "es" {
  description = "project es"
  default     = {}
  type        = any
}


variable "rds" {
  description = "project rds"
  default     = {}
  type        = any
}

variable "docdb" {
  description = "project docdb"
  default     = {}
  type        = any
}
variable "dynamodb" {
  description = "project dynamodb"
  default     = {}
  type        = any
}

variable "aurora" {
  description = "project aurora"
  default     = {}
  type        = any
}

variable "redis" {
  description = "project redis"
  default     = {}
  type        = any
}

variable "msk" {
  description = "project msk"
  default     = {}
  type        = any
}

variable "role_policy" {
  description = "role policy"
  default     = {}
  type        = any
}

variable "account_id" {
  description = "account id"
  default     = ""
  type        = string
}

variable "cce_domain" {
  description = "cdt domain"
  default     = ""
  type        = string
}

variable "aurora_parameters" {
  description = "A list of DB parameters (map) to apply"
  type        = list(map(string))
  default     = []
}

variable "media" {
  description = "media service parameters"
  default         = {}
  type            = any
}
