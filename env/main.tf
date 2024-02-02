provider "aws" {
  region = var.aws_region
  profile = "default"
}

module "vpc" {
  source = "../module/vpc"
  vpc    = var.vpc
  prefix = var.prefix
}

module "iam" {
  source = "../module/iam"
  prefix = var.prefix
}

module "s3" {
  source = "../module/s3"
  cloudfront_id = module.cloudfront.cloudfront_id
  oai_id = module.cloudfront.oai_id
}

module "route53" {
  source = "../module/route53"
}

module "cloudfront" {
  source            = "../module/cloudfront"
  bucket_id         = module.s3.bucket_id
  s3_bucket_domain_name = module.s3.s3_bucket_domain_name
}

module "frontend_ecr" {
  source = "../module/ecr"
  ecr    = var.frontend_ecr
  prefix = var.prefix
}

module "backend_ecr" {
  source = "../module/ecr"
  ecr    = var.backend_ecr
  prefix = var.prefix
}

#module "crons_ecr" {
#  source = "../module/ecr"
#  ecr    = var.crons_ecr
#  prefix = var.prefix
#}


module "alb_sg" {
  source = "../module/alb_sg"
  sg     = var.alb_sg
  vpc_id = module.vpc.vpc_id
  prefix = var.prefix
}

module "app_sg" {
  source             = "../module/app_sg"
  vpc_id             = module.vpc.vpc_id
  prefix             = var.prefix
  alb_security_group = module.alb_sg.security_group.id
}

module "rds" {
  source       = "../module/rds"
  rds          = var.rds
  vpc_id       = module.vpc.vpc_id
  subnets      = local.subnet_ids
  ecs_tasks_sg = module.app_sg.security_group.id
  sg = module.ssh_security_group.bastion_sg_id
  prefix       = var.prefix
}

module "ecs_cluster" {
  source = "../module/cluster"
  prefix = var.prefix
}

module "frontend_task_definition" {
  source             = "../module/task_definition"
  task_definition    = var.task_definition.frontend
  ecr_url            = module.frontend_ecr.ecr_url
  cluster_id        = module.ecs_cluster.cluster_id
  execution_role_arn = module.iam.ecs_task_execution_role
  aws_region         = var.aws_region
  prefix             = var.prefix
  environment        = local.environment
  secrets            = local.secrets
}

module "backend_task_definition" {
  source             = "../module/task_definition"
  task_definition    = var.task_definition.backend
  ecr_url            = module.backend_ecr.ecr_url
  cluster_id         = module.ecs_cluster.cluster_id
  execution_role_arn = module.iam.ecs_task_execution_role
  aws_region         = var.aws_region
  prefix             = var.prefix
  environment        = local.environment
  secrets            = local.secrets
}
#
#module "crons_task_definition" {
#  source             = "../module/task_definition"
#  task_definition    = var.task_definition.crons
#  ecr_url            = module.crons_ecr.ecr_url
#  cluster_id         = module.ecs_cluster.cluster_id
#  execution_role_arn = module.iam.ecs_task_execution_role
#  aws_region         = var.aws_region
#  prefix             = var.prefix
#  environment        = local.environment
#  secrets            = local.secrets
#}

module "frontend_alb" {
  source     = "../module/alb"
  alb_sg     = module.alb_sg.security_group.id
  subnet_ids = module.vpc.public_subnet_ids
  vpc_id     = module.vpc.vpc_id
  alb        = var.alb.frontend
  prefix     = var.prefix
}

module "backend_alb" {
  source     = "../module/alb"
  alb_sg     = module.alb_sg.security_group.id
  subnet_ids = module.vpc.public_subnet_ids
  vpc_id     = module.vpc.vpc_id
  alb        = var.alb.backend
  prefix     = var.prefix
}

#module "crons_alb" {
#  source     = "../module/alb"
#  alb_sg     = module.alb_sg.security_group.id
#  subnet_ids = module.vpc.public_subnet_ids
#  vpc_id     = module.vpc.vpc_id
#  alb        = var.alb.crons
#  prefix     = var.prefix
#}

module "frontend_ecs_service" {
  source               = "../module/service"
  ecs_service          = var.ecs_service.frontend
  cluster_name           = module.ecs_cluster.cluster_name
  task_definition_arn  = module.frontend_task_definition.ecs_task_definition.arn
  ecs_tasks_sg         = module.app_sg.security_group.id
  subnet_ids           = local.subnet_ids
  alb_target_group_arn = module.frontend_alb.target_group.arn
  target_group_port    = var.alb.frontend.target_group_port
  prefix               = var.prefix
  cluster_id        = module.ecs_cluster.cluster_id
}
#
module "backend_ecs_service" {
  source               = "../module/service"
  ecs_service          = var.ecs_service.backend
  cluster_id           = module.ecs_cluster.cluster_id
  cluster_name           = module.ecs_cluster.cluster_name
  task_definition_arn  = module.backend_task_definition.ecs_task_definition.arn
  ecs_tasks_sg         = module.app_sg.security_group.id
  subnet_ids           = local.subnet_ids
  alb_target_group_arn = module.backend_alb.target_group.arn
  target_group_port    = var.alb.backend.target_group_port
  prefix               = var.prefix
}
#
#module "crons_ecs_service" {
#  source               = "../module/service"
#  ecs_service          = var.ecs_service.crons
#  cluster_id           = module.ecs_cluster.cluster_id
#  task_definition_arn  = module.crons_task_definition.ecs_task_definition.arn
#  ecs_tasks_sg         = module.app_sg.security_group.id
#  subnet_ids           = local.subnet_ids
#  alb_target_group_arn = module.crons_alb.target_group.arn
#  target_group_port    = var.alb.crons.target_group_port
#  prefix               = var.prefix
#}
#
#module "general_fifo_queue" {
#  source = "../module/sqs"
#  prefix = var.prefix
#  sqs    = var.sqs.general_fifo_queue
#}
#
#module "general_fifo_sns_topic" {
#  source = "../module/sns"
#  prefix = var.prefix
#  sns    = var.sns.general_fifo_topic
#}
#
#module "sns_subscription_general_fifo_queue" {
#  source  = "../module/sns_subscription"
#  sqs_arn = module.general_fifo_queue.sqs_arn
#  sns_arn = module.general_fifo_sns_topic.sns_arn
#}
#
#module "sns_sqs_policy_general_fifo_sqs" {
#  source     = "../module/sns_sqs_policy"
#  sqs_arn    = module.general_fifo_queue.sqs_arn
#  sns_arn    = module.general_fifo_sns_topic.sns_arn
#  sqs_que_id = module.general_fifo_queue.sqs_id
#  prefix     = var.prefix
#}
#
module "ssh_security_group" {
  source = "../module/sg"
  vpc_id = module.vpc.vpc_id
}
#
##module "bastion_host" {
##  source             = "../module/bastion"
#  ami_id             = "ami-053b0d53c279acc90"
#  key_name           = "musa" #"bastion-host"
#  security_group_id  = module.ssh_security_group.bastion_sg_id
#  vpc_id = module.vpc.vpc_id
#  subnet_id = module.vpc.public_subnet_ids[0]
#}
