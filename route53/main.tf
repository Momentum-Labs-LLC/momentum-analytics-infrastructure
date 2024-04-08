provider "aws" {
  region = local.region
}

locals {
  env         = "prd"
  corp        = "momentum"
  iteration   = 0
  region      = "us-east-1"
  project     = "analytics"
  subproject  = "cdn"
  name_prefix = "${local.corp}-${local.env}-${local.project}-${local.subproject}"

  tags = {
    Production = "true"
    Project    = "${local.project}-${local.subproject}"
  }
}

resource "aws_acm_certificate" "mll-analytics-cert" {
  domain_name               = "mll-analytics.com"
  subject_alternative_names = ["*.mll-analytics.com"]
  validation_method         = "DNS"
}