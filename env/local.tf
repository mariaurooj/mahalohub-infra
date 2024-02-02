locals {
  subnet_ids = var.prefix.environment == "dev" ? module.vpc.public_subnet_ids : module.vpc.private_subnet_ids

  secrets = [
  #  {
  #    name      = "DB_PASS"
  #    valueFrom = module.rds.rds_password_arn
#
  #  }
  ]

  environment = [
    {
      name  = "AWS_REGION"
      value = "${var.aws_region}"
    },
    #{
    #  name  = "AWS_SNS_TOPIC_ARN"
    #  value = "${module.general_fifo_sns_topic.sns_arn}"
    #},
    #{
    #  name  = "AWS_SQS_GENERAL_QUEUE_URL"
    #  value = "${module.general_fifo_queue.sqs_url}"
    #},
    #{
    #  name  = "AWS_SQS_GENERAL_QUEUE_NAME"
    #  value = "${module.general_fifo_queue.sqs_name}"
    #},
    #{
    #  name  = "DB_HOST"
    #  value = element(split(":", module.rds.rds_endpoint), 0)
    #},
    #{
    #  name  = "DB_PORT"
    #  value = "5432"
    #},
    #{
    #  name  = "DB_USER"
    #  value = "${module.rds.db_user}"
    #},
    #{
    #  name  = "DB_NAME"
    #  value = "${module.rds.db_name}"
    #}
  ]
}