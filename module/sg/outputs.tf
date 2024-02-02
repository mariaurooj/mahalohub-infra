output "bastion_sg_id" {
  description = "The ID of the bastion security group"
  value       = aws_security_group.allow_ssh.id
}