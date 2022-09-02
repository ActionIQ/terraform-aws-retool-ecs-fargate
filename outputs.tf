output "stack_name" {
  value = local.stack-name
}

output "retool_alb_dns" {
  value = aws_lb.retool_alb.dns_name
}
