variable "vpc_id" {
  description = "The VPC ID where the security group should be created"
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks that should be allowed SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}