output "target_group" {
  value = aws_alb_target_group.default
}

output "alb" {
  value = aws_lb.default.dns_name
}