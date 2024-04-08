# This table is storage for Pii Values.
# Intentionally separate from the cookie id for easy detaching later.
resource "aws_dynamodb_table" "this-pii-values" {
  name             = "${local.table_name_prefix}-pii-values"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  hash_key = "Value"

  # A key for use in other tables. 
  attribute {
    name = "Id"
    type = "S"
  }

  # The pii value to be stored. Sensitive values should be hashed.
  attribute {
    name = "Value"
    type = "S"
  }

  # The type of pii.
  # attribute {
  #   name = "PiiTypeId"
  #   type = "N"
  # }

  # Specify the hashing algorithm. 
  # attribute {
  #   name = "HashAlgorithmId"
  #   type = "N"
  # }

  # The milliseconds since epoch for a UTC Timestamp
  # attribute {
  #   name = "UtcTimestamp"
  #   type = "N"
  # }

  global_secondary_index {
    name            = "IdIndex"
    hash_key        = "Id"
    projection_type = "ALL"
  }

  tags = merge(local.tags,
    tomap(
      {
        "Name" : "${local.table_name_prefix}-pii-values"
    })
  )
}