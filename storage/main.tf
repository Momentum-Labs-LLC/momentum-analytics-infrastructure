provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  env               = "prd"
  corp              = "momentum"
  iteration         = 0
  region            = "us-east-1"
  project           = "tracking"
  subproject        = "dynamo"
  table_name_prefix = "${local.corp}-${local.env}"

  tags = {
    Production = "true"
    Project    = "${local.project}-${local.subproject}"
  }
}