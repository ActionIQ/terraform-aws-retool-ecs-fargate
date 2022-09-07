output "retool_stack_name" {
  description = "Uniquely generated stack name for Retool on-premise deployment"
  value       = module.retool_self_hosted.stack_name
}
output "retool_alb_dns" {
  description = "Retool Application Load Balancer DNS FQDN"
  value       = module.retool_self_hosted.retool_alb_dns
}
output "retool_url" {
  description = "Valid Retool URL to access on-premise deployment"
  value       = module.retool_self_hosted.retool_url
}
