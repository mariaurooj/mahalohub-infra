###GLOBAL_VARIABLE_START###
variable "aws_region" {
  default = "us-west-2"
}
variable "vpc" {}

variable "frontend_ecr" {}

variable "backend_ecr" {}

variable "crons_ecr" {}

variable "prefix" {}

variable "task_definition" {}

variable "alb_sg" {}

variable "alb" {}

variable "ecs_service" {}

variable "rds" {}

#variable "sqs" {}

#variable "sns" {}
