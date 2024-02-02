################ task execution role #######################

resource "aws_iam_role" "task_execution_role" {
  name = "${var.prefix.environment}-${var.prefix.name}-ecs-task-role"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess", "arn:aws:iam::aws:policy/AmazonSSMFullAccess"]
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


########################## Task role ############################

data "aws_iam_policy_document" "ecs_service" {

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_service" {
  name                 = "${var.prefix.environment}-${var.prefix.name}-ecs-service-role"
  assume_role_policy   = join("", data.aws_iam_policy_document.ecs_service.*.json)
}

data "aws_iam_policy_document" "ecsexec" {
  statement {
    sid = ""
    effect = "Allow"

    actions = [
        "ssm:*",
        "secretsmanager:GetSecretValue",
        "ecs:ExecuteCommand",
        "ec2:DescribeTags",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:UpdateContainerInstancesState",
        "ecs:Submit*",
        "application-autoscaling:*",
        "ecs:DescribeServices",
        "ecs:UpdateService",
        "cloudwatch:DescribeAlarms",
        "cloudwatch:PutMetricAlarm",
        "cloudwatch:DeleteAlarms",
        "cloudwatch:DescribeAlarmHistory",
        "cloudwatch:DescribeAlarms",
        "cloudwatch:DescribeAlarmsForMetric",
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:ListMetrics",
        "cloudwatch:PutMetricAlarm",
        "cloudwatch:DisableAlarmActions",
        "cloudwatch:EnableAlarmActions",
        "iam:CreateServiceLinkedRole"
    ]

    resources = [
      "*",
    ]
  }

}


resource "aws_iam_policy" "ecsexec" {
  name   = "${var.prefix.environment}-${var.prefix.name}-ecsexec"
  path   = "/"
  policy = data.aws_iam_policy_document.ecsexec.json
}

resource "aws_iam_policy_attachment" "ecsexec" {
  name       = "${var.prefix.environment}-${var.prefix.name}-ecsexec"
  roles      = [aws_iam_role.ecs_service.name]
  policy_arn = aws_iam_policy.ecsexec.arn
}

data "aws_iam_policy_document" "ssm" {
  statement {
    sid = ""
    effect = "Allow"

    actions = [
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
    ]

    resources = [
      "*",
    ]
  }

}


resource "aws_iam_policy" "ssm" {
  name   = "${var.prefix.environment}-${var.prefix.name}-ssm"
  path   = "/"
  policy = data.aws_iam_policy_document.ssm.json
}

resource "aws_iam_policy_attachment" "ssm" {
  name       = "${var.prefix.environment}-${var.prefix.name}-ssm"
  roles      = [aws_iam_role.ecs_service.name]
  policy_arn = aws_iam_policy.ssm.arn
}