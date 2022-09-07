module "retool_self_hosted" {
  source                                     = "ActionIQ/retool-ecs-fargate/aws"
  retool_licence                             = "12345678-1234-1234-1234-123456789012"
  vpc_id                                     = "vpc-xxxx"
  availability_zones                         = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"]
  retool_alb_subnets                         = ["subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx"]
  retool_jobs_runner_ecs_service_subnet      = ["subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx"]
  retool_ecs_service_subnet                  = ["subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx"]
  retool_db_subnet_ids                       = ["subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx"]
  retool_rds_cluster_instance_count          = "1"
  retool_task_container_node_env             = "development"
  retool_jobs_runner_task_container_node_env = "development"

}
