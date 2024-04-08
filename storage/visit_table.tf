# A table for page views.
resource "aws_dynamodb_table" "this-visits" {
  name           = "${local.table_name_prefix}-visits"
  billing_mode   = "PAY_PER_REQUEST"
  stream_enabled = false

  # main primary key is request id
  # goal is prevent duplicate writes
  hash_key = "Id"

  attribute {
    name = "Id"
    type = "S"
  }

  attribute {
    name = "CookieId"
    type = "S"
  }

  attribute {
    name = "UtcExpiration"
    type = "N"
  }

  # The Pii Value identifying the user.
  attribute {
    name = "IsIdentified"
    type = "N"
  }

  # The days since epoch for a UTC Timestamp
  attribute {
    name = "UtcIdentifiedTimestamp"
    type = "N"
  }

  global_secondary_index {
    name            = "VisitExpirationIndex"
    hash_key        = "CookieId"
    range_key       = "UtcExpiration"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "IdentifiedIndex"
    hash_key        = "IsIdentified"
    range_key       = "UtcIdentifiedTimestamp"
    projection_type = "ALL"
  }

  tags = merge(local.tags,
    tomap(
      {
        "Name" : "${local.table_name_prefix}-identified-visits"
    })
  )
}