provider "aws" {
  region = local.region
}

locals {
  env         = "prd"
  corp        = "momentum"
  iteration   = 0
  region      = "us-east-1"
  project     = "analytics"
  subproject  = "alerting"
  name_prefix = "${local.corp}-${local.env}-${local.project}-${local.subproject}"

  tags = {
    Production = "true"
    Project    = "${local.project}-${local.subproject}"
  }
}

resource "aws_sns_topic" "alerts-topic" {
  name = local.name_prefix
}

resource "aws_sns_topic_subscription" "alerts-email" {
  topic_arn = aws_sns_topic.alerts-topic.arn
  protocol  = "email"
  endpoint  = "alerts@momentumlabsllc.com"
}