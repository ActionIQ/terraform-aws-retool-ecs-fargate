output "stack_name" {
  description = "Uniquely generated stack name for Retool on-premise deployment"
  value       = local.stack_name
}

output "retool_alb_dns" {
  description = "Retool Application Load Balancer DNS FQDN"
  value       = aws_lb.retool_alb.dns_name
}

output "retool_url" {
  description = "Valid Retool URL to access on-premise deployment"
  value       = var.retool_custom_host_url != null && var.route_53_zone_id != null ? "${lower(local.retool_alb_listener_protocol)}://${aws_route53_record.retool_custom_host_url[0].fqdn}${local.retool_url_port}" : null
}

output "retool_rds_instance_arn" {
  description = "ARN of the Aurora DB instance"
  value       = aws_rds_cluster.retool_postgresql.arn
}
