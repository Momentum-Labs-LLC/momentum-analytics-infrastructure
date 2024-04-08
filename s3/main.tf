provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  env         = "prd"
  corp        = "momentum"
  iteration   = 0
  region      = "us-east-1"
  project     = "analytics"
  subproject  = "s3"
  name_prefix = "${local.corp}-${local.env}"

  tags = {
    Production = "true"
    Project    = "${local.project}-${local.subproject}"
  }
}

resource "aws_s3_bucket" "this-bucket" {
  bucket = "${local.name_prefix}-identified-visits-${local.iteration}"

  tags = merge(local.tags,
    tomap(
      {
        "Name" = "${local.name_prefix}-identified-visits-${local.iteration}"
      }
  ))
}