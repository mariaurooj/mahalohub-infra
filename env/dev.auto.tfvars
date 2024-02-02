prefix = {
  name        = "mahalohub"
  environment = "dev"
}

aws_region = "us-east-1"


vpc = {
  vpc_cidr_block  = "10.0.0.0/16"
  public_subnets  = ["10.0.0.0/24", "10.0.8.0/24"]
  private_subnets = ["10.0.40.0/24", "10.0.48.0/24"]

  enable_nat_gateway = false
  single_nat_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true
}

frontend_ecr = {
  name         = "frontend"
  rulePriority = 1
  description  = "keep last 5 images"
  countType    = "imageCountMoreThan"
  countNumber  = 5
}

backend_ecr = {
  name         = "backend"
  rulePriority = 1
  description  = "keep last 5 images"
  countType    = "imageCountMoreThan"
  countNumber  = 5
}

crons_ecr = {
  name         = "crons"
  rulePriority = 1
  description  = "keep last 5 images"
  countType    = "imageCountMoreThan"
  countNumber  = 5
}

task_definition = {
  frontend = {
    name           = "frontend"
    fargate_cpu    = 1024
    fargate_memory = 2048
    port           = 8000
  },
  backend = {
    name           = "backend"
    fargate_cpu    = 1024
    fargate_memory = 2048
    port           = 3001
  }
  crons = {
    name           = "crons"
    fargate_cpu    = 1024
    fargate_memory = 2048
    port           = 8002
  }

}

alb_sg = {
  name        = "alb-sg"
  description = "alb security group"
  ingress_rules = [
    {
      cidr_blocks = "0.0.0.0/0"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP traffic from internet"
    },
    {
      cidr_blocks = "0.0.0.0/0"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS traffic from internet"
    }
  ]

  egress_rules = [
    {
      cidr_blocks = "0.0.0.0/0"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = ""
    }
  ]
}


alb = {
  frontend = {
    name                       = "frontend"
    target_group_port          = 8000
    internal                   = false
    load_balancer_type         = "application"
    enable_deletion_protection = false
    health_check = {
      healthy_threshold   = "3"
      interval            = "30"
      protocol            = "HTTP"
      matcher             = "200"
      timeout             = "3"
      path                = "/" # "Http path for task health check"
      unhealthy_threshold = "2"
    }
  },
  backend = {
    name                       = "backend"
    target_group_port          = 3001
    internal                   = false
    load_balancer_type         = "application"
    enable_deletion_protection = false
    health_check = {
      healthy_threshold   = "3"
      interval            = "30"
      protocol            = "HTTP"
      matcher             = "200"
      timeout             = "3"
      path                = "/" # "Http path for task health check"
      unhealthy_threshold = "2"
    }
  }
  crons = {
    name                       = "crons"
    target_group_port          = 8002
    internal                   = false
    load_balancer_type         = "application"
    enable_deletion_protection = false
    health_check = {
      healthy_threshold   = "3"
      interval            = "30"
      protocol            = "HTTP"
      matcher             = "200"
      timeout             = "3"
      path                = "/" # "Http path for task health check"
      unhealthy_threshold = "2"
    }
  }
}

ecs_service = {
  frontend = {
    name                              = "frontend"
    assign_public_ip                  = true
    desired_count                     = 1
    health_check_grace_period_seconds = 300
    autoscaling_min_capacity          = 1
    autoscaling_max_capacity          = 10
    autoscaling_scale_down_adjustment = -1
    autoscaling_scale_down_cooldown   = 300
    autoscaling_scale_up_adjustment   = 1
    autoscaling_scale_up_cooldown     = 60
    cpu_threshold_to_scale_up_task    = 70
    cpu_threshold_to_scale_down_task  = 20
  },
  backend = {
    name                              = "backend"
    assign_public_ip                  = true
    desired_count                     = 1
    health_check_grace_period_seconds = 300
    autoscaling_min_capacity          = 1
    autoscaling_max_capacity          = 10
    autoscaling_scale_down_adjustment = -1
    autoscaling_scale_down_cooldown   = 300
    autoscaling_scale_up_adjustment   = 1
    autoscaling_scale_up_cooldown     = 60
    cpu_threshold_to_scale_up_task    = 70
    cpu_threshold_to_scale_down_task  = 20
  }
  crons = {
    name                              = "crons"
    assign_public_ip                  = true
    desired_count                     = 1
    health_check_grace_period_seconds = 300
    autoscaling_min_capacity          = 1
    autoscaling_max_capacity          = 10
    autoscaling_scale_down_adjustment = -1
    autoscaling_scale_down_cooldown   = 300
    autoscaling_scale_up_adjustment   = 1
    autoscaling_scale_up_cooldown     = 60
    cpu_threshold_to_scale_up_task    = 70
    cpu_threshold_to_scale_down_task  = 20
  }

}


rds = {
  identifier                   = "mahalohub-dev-frontend"
  allocated_storage            = "20"
  storage_type                 = "gp3"
  engine                       = "mysql"
  engine_version               = "8.0.35"
  instance_class               = "db.t3.micro"
  db_name                      = "mahalohub_frontend_db"
  username                     = "secret_user"
  #parameter_group_name         = "default.mysql8.0.35"
  backup_retention_period      = "7"
  backup_window                = "00:00-00:30"
  skip_final_snapshot          = true
  publicly_accessible          = false
  multi_az                     = false
  auto_minor_version_upgrade   = true
  #performance_insights_enabled = true
  allow_major_version_upgrade  = true
}

/*sqs = {
  general_fifo_queue = {
    name                        = "general-fifo-queue.fifo"
    delay_seconds               = 0
    max_message_size            = 262144
    message_retention_seconds   = 345600
    visibility_timeout_seconds  = 30
    receive_wait_time_seconds   = 0
    fifo_queue                  = true
    content_based_deduplication = true
  }

}

sns = {
  general_fifo_topic = {
    name                        = "general-fifo-topic.fifo"
    fifo_topic                  = true
    content_based_deduplication = true
  }
}*/