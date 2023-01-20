resource "random_id" "stack_name_random" {
  byte_length = 4
}

resource "aws_security_group" "retool_alb" {
  name        = "${local.stack_name}-alb"
  description = "${local.stack_name} load balancer security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = local.retool_alb_ingress_port
    protocol    = "tcp"
    to_port     = var.retool_task_container_port
    cidr_blocks = var.retool_alb_sg_ingress_cidr_blocks
  }

  egress {
    description = "Allow all egress traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.retool_alb_sg_egress_cidr_blocks
  }

  tags = {
    Name = "${local.stack_name}-alb"
  }
}

resource "aws_cloudwatch_log_group" "retool_log_group" {
  name = local.stack_name
}

resource "aws_security_group" "retool_rds" {
  name        = "${local.stack_name}-rds"
  description = "${local.stack_name} database security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.postgresql_db_port
    protocol    = "tcp"
    to_port     = var.postgresql_db_port
    cidr_blocks = var.retool_rds_sg_ingress_cidr_blocks
  }

  egress {
    description = "Allow all egress traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.retool_rds_sg_egress_cidr_blocks
  }

  tags = {
    Name = "${local.stack_name}-rds"
  }
}

resource "aws_db_subnet_group" "retool_db_subnet_sg" {
  name       = "${local.stack_name}-db_subnet_sg"
  subnet_ids = var.retool_db_subnet_ids
}

resource "aws_ecs_cluster" "retool_ecs_cluster" {
  name = local.stack_name
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {}
}

resource "aws_ecs_task_definition" "retool_task" {
  family                   = "${local.stack_name}-backend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = var.retool_task_network_mode
  cpu                      = var.retool_task_cpu
  memory                   = var.retool_task_memory
  task_role_arn            = aws_iam_role.retool_task_role.arn
  execution_role_arn       = aws_iam_role.retool_execution_role.arn
  container_definitions    = <<TASK_DEFINITION
[
  {
    "command": ["./docker_scripts/start_api.sh"],
    "environment": ${local.ecs_env_vars}
    "logConfiguration": {
      "logDriver": "${var.retool_ecs_tasks_logdriver}",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.retool_log_group.name}",
        "awslogs-region": "${var.aws_region}",
        "awslogs-stream-prefix": "${var.retool_ecs_tasks_log_prefix}"
      }
    },
    "essential": true,
    "image": "${local.retool_image}",
    "name": "${var.retool_task_container_name}",
    "portMappings": [
      {
        "containerPort": ${var.retool_task_container_port}
      }
    ]
  }
]
TASK_DEFINITION
  tags                     = {}
}

resource "aws_ecs_task_definition" "retool_jobs_runner_task" {
  family                   = "${local.stack_name}-jobs-runner"
  requires_compatibilities = ["FARGATE"]
  network_mode             = var.retool_jobs_runner_task_network_mode
  cpu                      = var.retool_jobs_runner_task_cpu
  memory                   = var.retool_jobs_runner_task_memory
  task_role_arn            = aws_iam_role.retool_task_role.arn
  execution_role_arn       = aws_iam_role.retool_execution_role.arn
  container_definitions    = <<TASK_DEFINITION
[
  {
    "command": ["./docker_scripts/start_api.sh"],
    "environment": [
      {"name": "NODE_ENV", "value": "${var.retool_jobs_runner_task_container_node_env}"},
      {"name": "SERVICE_TYPE", "value": "${var.retool_jobs_runner_task_container_service_type}"},
      {"name": "FORCE_DEPLOYMENT", "value": "${var.retool_jobs_runner_task_container_force_deployment}"},
      {"name": "POSTGRES_DB", "value": "${local.database_name}"},
      {"name": "POSTGRES_HOST", "value": "${aws_rds_cluster.retool_postgresql.endpoint}"},
      {"name": "POSTGRES_SSL_ENABLED", "value": "${var.postgresql_ssl_enabled}"},
      {"name": "POSTGRES_PORT", "value": "${var.postgresql_db_port}"},
      {"name": "POSTGRES_USER", "value": "${local.retool_rds_secret.username}"},
      {"name": "POSTGRES_PASSWORD", "value": "${local.retool_rds_secret.password}"},
      {"name": "JWT_SECRET", "value": "${local.retool_jwt_secret.password}"},
      {"name": "ENCRYPTION_KEY", "value": "${local.retool_encryption_key_secret.password}"},
      {"name": "LICENSE_KEY", "value": "${var.retool_licence}"},
      {"name": "COOKIE_INSECURE", "value": "${var.retool_jobs_runner_task_container_cookie_insecure}"}
    ],
    "logConfiguration": {
      "logDriver": "${var.retool_ecs_tasks_logdriver}",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.retool_log_group.name}",
        "awslogs-region": "${var.aws_region}",
        "awslogs-stream-prefix": "${var.retool_ecs_tasks_log_prefix}"
      }
    },
    "essential": true,
    "image": "${local.retool_image}",
    "name": "${var.retool_jobs_runner_task_container_name}"
  }
]
TASK_DEFINITION
  tags                     = {}
}

resource "random_password" "retool_jwt_secret" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "retool_jwt_secret" {
  name = "${local.stack_name}-jwt-secret"
}

resource "aws_secretsmanager_secret_version" "retool_jwt_secret" {
  secret_id     = aws_secretsmanager_secret.retool_jwt_secret.id
  secret_string = jsonencode(local.retool_jwt_secret)
}

resource "random_password" "retool_encryption_key_secret" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "retool_encryption_key_secret" {
  name = "${local.stack_name}-encryption-key-secret"
}

resource "aws_secretsmanager_secret_version" "retool_encryption_key_secret" {
  secret_id     = aws_secretsmanager_secret.retool_encryption_key_secret.id
  secret_string = jsonencode(local.retool_encryption_key_secret)
}

resource "random_password" "retool_rds_secret" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "retool_rds_secret" {
  name = "${local.stack_name}-rds-secret"
}

resource "aws_secretsmanager_secret_version" "retool_rds_secret" {
  secret_id     = aws_secretsmanager_secret.retool_rds_secret.id
  secret_string = jsonencode(local.retool_rds_secret)
}

resource "aws_rds_cluster" "retool_postgresql" {
  cluster_identifier      = "${local.stack_name}-cluster"
  db_subnet_group_name    = aws_db_subnet_group.retool_db_subnet_sg.name
  engine                  = var.retool_rds_cluster_engine
  engine_version          = var.retool_rds_cluster_engine_version
  availability_zones      = var.availability_zones
  vpc_security_group_ids  = [aws_security_group.retool_rds.id]
  database_name           = local.database_name
  master_username         = local.retool_rds_secret.username
  master_password         = local.retool_rds_secret.password
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = "true"
}

resource "aws_rds_cluster_instance" "retool_cluster_instances" {
  count              = var.retool_rds_cluster_instance_count
  identifier         = "${local.stack_name}-aurora-cluster-${count.index}"
  cluster_identifier = aws_rds_cluster.retool_postgresql.id
  instance_class     = var.retool_rds_cluster_instance_class
  engine             = aws_rds_cluster.retool_postgresql.engine
  engine_version     = aws_rds_cluster.retool_postgresql.engine_version
}

resource "aws_lb" "retool_alb" {
  name               = local.stack_name
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.retool_alb.id]
  subnets            = var.retool_alb_subnets
}

resource "aws_lb_listener" "retool_alb" {
  load_balancer_arn = aws_lb.retool_alb.arn
  port              = local.retool_alb_ingress_port
  protocol          = local.retool_alb_listener_protocol
  ssl_policy        = local.retool_alb_listener_ssl_policy
  certificate_arn   = local.retool_alb_listener_certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.retool_alb.arn
  }
}

resource "aws_alb_listener_rule" "retool_alb" {
  listener_arn = aws_lb_listener.retool_alb.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.retool_alb.arn
  }
  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

resource "aws_alb_target_group" "retool_alb" {
  name                 = "${local.stack_name}-tg"
  port                 = var.retool_task_container_port
  protocol             = var.aws_alb_target_group_protocol
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = 30

  health_check {
    interval            = 61
    path                = "/api/checkHealth"
    protocol            = "HTTP"
    timeout             = 60
    healthy_threshold   = 4
    unhealthy_threshold = 10
  }
}

resource "aws_ecs_service" "retool_ecs_service" {
  name                               = "${local.stack_name}-ecs-service"
  cluster                            = aws_ecs_cluster.retool_ecs_cluster.arn
  deployment_maximum_percent         = var.retool_ecs_service_deploy_max
  deployment_minimum_healthy_percent = var.retool_ecs_service_deploy_min_health
  task_definition                    = aws_ecs_task_definition.retool_task.arn
  desired_count                      = var.retool_ecs_service_count
  # iam_role = aws_iam_role.retool_service_role.arn
  launch_type = "FARGATE"
  depends_on  = [aws_lb_listener.retool_alb]

  load_balancer {
    container_name   = var.retool_task_container_name
    container_port   = var.retool_task_container_port
    target_group_arn = aws_alb_target_group.retool_alb.arn
  }

  network_configuration {
    subnets         = var.retool_ecs_service_subnet
    security_groups = [aws_security_group.retool_alb.id]
  }
}

resource "aws_ecs_service" "retool_jobs_runner_ecs_service" {
  name            = "${local.stack_name}-jobs-runner-ecs-service"
  cluster         = aws_ecs_cluster.retool_ecs_cluster.arn
  task_definition = aws_ecs_task_definition.retool_jobs_runner_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.retool_jobs_runner_ecs_service_subnet
    security_groups = [aws_security_group.retool_alb.id]
  }
}

resource "aws_iam_role" "retool_service_role" {
  name = "${local.stack_name}-service-role"
  path = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "${local.stack_name}-env-service-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
            "elasticloadbalancing:DeregisterTargets",
            "elasticloadbalancing:Describe*",
            "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
            "elasticloadbalancing:RegisterTargets",
            "ec2:Describe*",
            "ec2:AuthorizeSecurityGroupIngress"
          ]
          Effect   = "Allow"
          Resource = "*"
      }]
    })
  }
}

resource "aws_iam_role" "retool_task_role" {
  name = "${local.stack_name}-task-role"
  path = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role" "retool_execution_role" {
  name = "${local.stack_name}-execution-role"
  path = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "${local.stack_name}-env-execution-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Effect   = "Allow"
          Resource = "*"
      }]
    })
  }
}

resource "aws_route53_record" "retool_custom_host_url" {
  count   = var.retool_custom_host_url != null && var.route_53_zone_id != null ? 1 : 0
  name    = var.retool_custom_host_url
  type    = "A"
  zone_id = var.route_53_zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_lb.retool_alb.dns_name
    zone_id                = aws_lb.retool_alb.zone_id
  }
}
