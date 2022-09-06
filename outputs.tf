output "stack_name" {
  value = local.stack-name
}

output "retool_alb_dns" {
  value = aws_lb.retool_alb.dns_name
}

output "retool_url" {
  value = var.retool_custom_host_url != null && var.route_53_zone_id != null ? "${lower(var.aws_lb_listener_protocol)}://${aws_route53_record.retool_custom_host_url[0].fqdn}:${var.retool_alb_ingress_port}" : null
}
