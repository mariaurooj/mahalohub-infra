data "aws_caller_identity" "current" {}

resource "aws_ecs_service" "default" {
  name                               = "${var.prefix.environment}-${var.prefix.name}-${var.ecs_service.name}"
  cluster                            = var.cluster_id
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  desired_count                      = 1
  health_check_grace_period_seconds  = 60
  launch_type                        = "FARGATE"
  task_definition                    = var.task_definition_arn

  load_balancer {
    container_name   = "${var.prefix.environment}-${var.prefix.name}-${var.ecs_service.name}"
    container_port   = 80 #var.target_group_port
    target_group_arn = var.alb_target_group_arn
  }

  network_configuration {
    assign_public_ip = var.ecs_service.assign_public_ip
    security_groups = [
      var.ecs_tasks_sg
    ]
    subnets = var.subnet_ids
  }

  tags = {
    Name        = "${var.prefix.environment}-${var.prefix.name}-${var.ecs_service.name}"
    Environment = var.prefix.environment
    Terraform   = "Yes"
  }
}

# ECS AutoScaling

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.default.name}"
  role_arn           = format("arn:aws:iam::%s:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService", data.aws_caller_identity.current.account_id)
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = 80
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 60
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

######################################
# module "ecs_cloudwatch_autoscaling" {
#   source                = "cloudposse/ecs-cloudwatch-autoscaling/aws"
#   version               = "0.7.2"
#   name                  = "${var.prefix.environment}-${var.ecs_service.name}-autoscaling"
#   namespace             = "${var.prefix.environment}-${var.prefix.name}-${var.ecs_service.name}"
#   stage                 = "${var.prefix.environment}-${var.prefix.name}-${var.ecs_service.name}"
#   service_name          = "${var.prefix.environment}-${var.prefix.name}-${var.ecs_service.name}"
#   cluster_name          = var.cluster_id
#   min_capacity          = var.ecs_service.autoscaling_min_capacity
#   max_capacity          = var.ecs_service.autoscaling_max_capacity
#   scale_down_adjustment = var.ecs_service.autoscaling_scale_down_adjustment
#   scale_down_cooldown   = var.ecs_service.autoscaling_scale_down_cooldown
#   scale_up_adjustment   = var.ecs_service.autoscaling_scale_up_adjustment
#   scale_up_cooldown     = var.ecs_service.autoscaling_scale_up_cooldown
# }

# resource "aws_cloudwatch_metric_alarm" "scale-up" {
#   alarm_name          = "${var.prefix.environment}-${var.ecs_service.name}-scale-up-alarm"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "1"
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/ECS"
#   period              = "60"
#   statistic           = "Average"
#   threshold           = var.ecs_service.cpu_threshold_to_scale_up_task

#   dimensions = {
#     ClusterName = var.cluster_id
#     ServiceName = "${var.prefix.environment}-${var.prefix.name}-${var.ecs_service.name}"
#   }

#   alarm_description = "This metric monitors ecs cpu utilization"
#   alarm_actions     = [module.ecs_cloudwatch_autoscaling.scale_up_policy_arn]
# }
# resource "aws_cloudwatch_metric_alarm" "scale-down" {
#   alarm_name          = "${var.prefix.environment}-${var.ecs_service.name}-scale-down-alarm"
#   comparison_operator = "LessThanOrEqualToThreshold"
#   evaluation_periods  = "1"
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/ECS"
#   period              = "60"
#   statistic           = "Average"
#   threshold           = var.ecs_service.cpu_threshold_to_scale_down_task

#   dimensions = {
#     ClusterName = var.cluster_id
#     ServiceName = "${var.prefix.environment}-${var.prefix.name}-${var.ecs_service.name}"
#   }

#   alarm_description = "This metric monitors ecs cpu utilization"
#   alarm_actions     = [module.ecs_cloudwatch_autoscaling.scale_down_policy_arn]
# }