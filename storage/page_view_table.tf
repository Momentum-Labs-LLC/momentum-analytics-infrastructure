# A table for page views.
resource "aws_dynamodb_table" "this-page-view" {
  name             = "${local.table_name_prefix}-page-views"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  # main primary key is request id
  # goal is prevent duplicate writes
  hash_key  = "CookieId"
  range_key = "UtcTimestamp"

  # The cookie identifier.
  attribute {
    name = "CookieId"
    type = "S"
  }

  # The milliseconds since epoch for the page view.
  attribute {
    name = "UtcTimestamp"
    type = "N"
  }

  # The path of the page view
  # attribute {
  #   name = "Path"
  #   type = "S"
  # }

  # The conversion funnel step of the page view.
  # attribute {
  #   name = "FunnelStepId"
  #   type = "N"
  # }

  # The referrer host of the page view.
  # attribute {
  #   name = "Referer"
  #   type = "S"
  # }

  # The utm_source value of the page view.
  # attribute {
  #   name = "Source"
  #   type = "S"
  # }

  # The utm_medium value of the page view.
  # attribute {
  #   name = "Medium"
  #   type = "S"
  # }

  tags = merge(local.tags,
    tomap(
      {
        "Name" : "${local.table_name_prefix}-page-views"
    })
  )
}