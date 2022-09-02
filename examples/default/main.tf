module "retool-self-hosted" {
  source = "terraform-aws-retool-ecs-fargate"
  retool_licence = "12345678-1234-1234-1234-123456789012"
  vpc_id = "vpc-xxxx"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"]
  retool_alb_subnets = ["subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx"]
  retool_jobs_runner_ecs_service_subnet = ["subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx"]
  retool_ecs_service_subnet = ["subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx"]
  retool_db_subnet_ids = ["subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx"]
}

output "retool_stack_name" {
  value = module.retool-self-hosted.stack_name
}
output "retool_alb_dns" {
  value = module.retool-self-hosted.retool_alb_dns
}