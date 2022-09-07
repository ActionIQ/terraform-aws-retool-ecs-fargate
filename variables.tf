variable "retool_licence" {
  description = "Retool license for self-hosting."
  type        = string
  default     = ""
}

locals {
  stack_name    = "${var.stack_name}-${random_id.stack_name_random.hex}"
  database_name = var.database_name
  retool_image  = "tryretool/backend:${var.retool_release_version}"
  retool_jwt_secret = {
    password = random_password.retool_jwt_secret.result
  }
  retool_encryption_key_secret = {
    password = random_password.retool_encryption_key_secret.result
  }
  retool_rds_secret = {
    username = "retool"
    password = random_password.retool_rds_secret.result
  }
}

variable "aws_region" {
  description = "AWS Region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "stack_name" {
  description = "Base Retool stack name"
  type        = string
  default     = "retool-self-hosted"
}

variable "database_name" {
  description = "Retool postgresql database name"
  type        = string
  default     = "hammerhead_production"
}

variable "postgresql_ssl_enabled" {
  description = "Enable or disable postgresql SSL"
  type        = bool
  default     = true
}

variable "postgresql_db_port" {
  description = "Postgresql RDS listening port"
  type        = number
  default     = "5432"
}

variable "retool_release_version" {
  description = "Official Retool release version found: https://github.com/tryretool/retool-onpremise#select-a-retool-version-number"
  type        = string
  default     = "2.93.9"
}

variable "retool_alb_sg_ingress_cidr_blocks" {
  description = "Cidr block allowed to ingress the Retool ALB"
  type        = string
  default     = "0.0.0.0/0"
}

variable "retool_alb_sg_egress_cidr_blocks" {
  description = "Cidr block allowed to egress the Retool ALB"
  type        = string
  default     = "0.0.0.0/0"
}

variable "retool_rds_sg_ingress_cidr_blocks" {
  description = "Cidr block allowed to ingress the Retool RDS DB"
  type        = string
  default     = "0.0.0.0/0"
}

variable "retool_rds_sg_egress_cidr_blocks" {
  description = "Cidr block allowed to egress the Retool RDS DB"
  type        = string
  default     = "0.0.0.0/0"
}

variable "retool_task_network_mode" {
  description = "The Docker networking mode to use for the containers in the task"
  type        = string
  default     = "awsvpc"
}

variable "retool_task_cpu" {
  description = "The hard limit of CPU units to present for the task. It can be expressed as an integer using CPU units (for example, 1024)"
  type        = number
  default     = "1024"
}

variable "retool_task_memory" {
  description = "The hard limit of memory (in MiB) to present to the task. It can be expressed as an integer using MiB (for example 2048)"
  type        = number
  default     = "2048"
}

variable "retool_task_container_node_env" {
  description = "Set Retool task container environment"
  type        = string
  default     = "production"
}

variable "retool_task_container_service_type" {
  description = "Retool task container service type"
  type        = string
  default     = "MAIN_BACKEND,DB_CONNECTOR"
}

variable "retool_task_container_force_deployment" {
  description = "Set if Terraform should force deploy regardless if change has been detected"
  type        = bool
  default     = false
}

variable "retool_task_container_cookie_insecure" {
  description = "Allow cookies to be insecure e.g. not using Retool over https"
  type        = bool
  default     = true
}

variable "retool_task_container_name" {
  description = "Name of Retool task"
  type        = string
  default     = "retool"
}

variable "retool_task_container_port" {
  description = "Retool task listening port"
  type        = number
  default     = "3000"
}

variable "retool_jobs_runner_task_network_mode" {
  description = "The Docker networking mode to use for the containers in the task"
  type        = string
  default     = "awsvpc"
}

variable "retool_jobs_runner_task_cpu" {
  description = "The hard limit of CPU units to present for the task. It can be expressed as an integer using CPU units (for example, 1024)"
  type        = number
  default     = "1024"
}

variable "retool_jobs_runner_task_memory" {
  description = "The hard limit of memory (in MiB) to present to the task. It can be expressed as an integer using MiB (for example 2048)"
  type        = number
  default     = "2048"
}

variable "retool_jobs_runner_task_container_node_env" {
  description = "Set Retool jobs runner task container environment"
  type        = string
  default     = "production"
}

variable "retool_jobs_runner_task_container_service_type" {
  description = "Retool jobs runner task container service type"
  type        = string
  default     = "JOBS_RUNNER"
}

variable "retool_jobs_runner_task_container_force_deployment" {
  description = "Set if Terraform should force deploy regardless if change has been detected"
  type        = bool
  default     = false
}

variable "retool_jobs_runner_task_container_cookie_insecure" {
  description = "Allow cookies to be insecure e.g. not using Retool over https"
  type        = bool
  default     = true
}

variable "retool_jobs_runner_task_container_name" {
  description = "Name of Retool jobs runner task"
  type        = string
  default     = "retool-jobs-runner"
}

variable "retool_ecs_tasks_logdriver" {
  description = "Send log information to CloudWatch Logs"
  type        = string
  default     = "awslogs"
}

variable "retool_ecs_tasks_log_prefix" {
  description = "Associate a log stream with the specified prefix, the container name, and the ID of the Amazon ECS task that the container belongs to"
  type        = string
  default     = "SERVICE_RETOOL"
}

variable "retool_alb_ingress_port" {
  description = "Retool ALB ingress port"
  type        = number
  default     = "3000"
}

variable "retool_rds_cluster_engine" {
  description = "AWS RDS Cluster engine flavor"
  type        = string
  default     = "aurora-postgresql"
}

variable "retool_rds_cluster_engine_version" {
  description = "AWS RDS Cluster engine version - this is despendent on var.retool_rds_cluster_engine"
  type        = number
  default     = "11.13"
}

variable "retool_rds_cluster_instance_count" {
  description = "Retool RDS Cluster Instance count"
  type        = number
  default     = "2"
}

variable "retool_rds_cluster_instance_class" {
  description = "Retool RDS RDS Cluster Instance flavor"
  type        = string
  default     = "db.r4.large"
}

variable "vpc_id" {
  description = "AWS VPC for Fargate and ALB to utilize"
  type        = string
}

variable "availability_zones" {
  description = "AWS VPC for Fargate and ALB to utilize"
  type        = list(string)
}

variable "retool_alb_subnets" {
  description = "AWS VPC for Fargate and ALB to utilize"
  type        = list(string)
}

variable "retool_jobs_runner_ecs_service_subnet" {
  description = "AWS VPC for Fargate and ALB to utilize"
  type        = list(string)
}

variable "retool_ecs_service_subnet" {
  description = "AWS VPC for Fargate and ALB to utilize"
  type        = list(string)
}

variable "retool_db_subnet_ids" {
  description = "AWS VPC for Fargate and ALB to utilize"
  type        = list(string)
}

variable "aws_lb_listener_protocol" {
  description = "AWS ALB listening protocol e.g HTTP, HTTPS etc"
  type        = string
  default     = "HTTP"
}

variable "aws_alb_target_group_protocol" {
  description = "Protocol ALB should use to talk with target group e.g HTTP, HTTPS etc"
  type        = string
  default     = "HTTP"
}

variable "retool_ecs_service_deploy_max" {
  description = "Upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment"
  type        = number
  default     = "250"
}

variable "retool_ecs_service_deploy_min_health" {
  description = "Lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment"
  type        = number
  default     = "50"
}

variable "retool_ecs_service_count" {
  description = "Number of instances of the task definition to place and keep running"
  type        = number
  default     = "2"
}

variable "retool_custom_host_url" {
  description = "Specify a custom hostname that will be used to create a custom url instead of the Load Balancer address. e.g. retool"
  type        = string
  default     = null
}

variable "route_53_zone_id" {
  description = "AWS Route53 zone_id to create retool_custom_url record in"
  type        = string
  default     = null
}
