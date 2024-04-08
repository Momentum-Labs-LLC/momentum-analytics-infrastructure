# A table for connecting PII and specific visits.
# Delete records from here if you ever need to detach pii from a visit/visitor
resource "aws_dynamodb_table" "this-collected-pii" {
  name             = "${local.table_name_prefix}-collected-pii"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  hash_key  = "PiiId"
  range_key = "UtcTimestamp"

  # Pii Identifier to link to the hashed pii table.
  attribute {
    name = "PiiId"
    type = "S"
  }

  # Cookie Identifier to attach to a specific visit
  attribute {
    name = "CookieId"
    type = "S"
  }

  # The timestamp of the data collection
  attribute {
    name = "UtcTimestamp"
    type = "N"
  }

  # Secondary index for looking up which PII was collected for a specific CookieId
  global_secondary_index {
    name            = "CookieTimestampIndex"
    hash_key        = "CookieId"
    range_key       = "UtcTimestamp"
    projection_type = "ALL"
  }

  tags = merge(local.tags,
    tomap(
      {
        "Name" : "${local.table_name_prefix}-collected-pii"
    })
  )
}