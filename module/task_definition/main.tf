resource "aws_cloudwatch_log_group" "this" {
  name = "/ecs/${var.prefix.environment}/${var.prefix.name}/${var.task_definition.name}"

  tags = {
    Name        = "${var.prefix.environment}-${var.prefix.name}-${var.task_definition.name}"
    Environment = var.prefix.environment
  }
}

resource "aws_ecs_task_definition" "default" {
  container_definitions = jsonencode([{
    name : "${var.prefix.environment}-${var.prefix.name}-${var.task_definition.name}",
    image : "nginx:latest",
    cpu : var.task_definition.fargate_cpu,
    memory : var.task_definition.fargate_memory,
    environment = var.environment,
    secrets = var.secrets,
    networkMode : "awsvpc",
    logConfiguration : {
      "logDriver" : "awslogs",
      "options" : {
        "awslogs-group" : aws_cloudwatch_log_group.this.name
        "awslogs-region" : var.aws_region,
        "awslogs-stream-prefix" : "ecs-logs"
      }
    },
    portMappings : [
      {
        "protocol" : "tcp"
        "containerPort" : 80 ,#var.task_definition.port,
        "hostPort" : 80 ,#var.task_definition.port,
      }
    ],
    essential : true,
  }])
  cpu                      = var.task_definition.fargate_cpu
  execution_role_arn       = var.execution_role_arn
  family                   = "${var.prefix.environment}-${var.prefix.name}-${var.task_definition.name}"
  memory                   = var.task_definition.fargate_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  depends_on = [
    var.cluster_id,
  ]

  tags = {
    Name        = "${var.prefix.environment}-${var.prefix.name}-${var.task_definition.name}"
    Environment = var.prefix.environment
  }
}
