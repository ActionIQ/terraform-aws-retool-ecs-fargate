module "retool_self_hosted" {
  source                                = "ActionIQ/retool-ecs-fargate/aws"
  retool_licence                        = "12345678-1234-1234-1234-123456789012"
  vpc_id                                = "vpc-xxxx"
  availability_zones                    = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"]
  retool_alb_subnets                    = ["subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx"]
  retool_jobs_runner_ecs_service_subnet = ["subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx"]
  retool_ecs_service_subnet             = ["subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx"]
  retool_db_subnet_ids                  = ["subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx", "subnet-xxxx"]
  retool_custom_host_url                = "fancy-url"
  route_53_zone_id                      = "Z12345678901234567890"
  alb_listener_certificate_arn          = "arn:aws:acm:us-east-1:123456789012:certificate/1234567A-1234-1234-1234-123456789012"
}
