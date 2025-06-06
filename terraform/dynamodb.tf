
module "dynamodb_table" {
  source            = "git::https://github.com/jaydipd/dynamodb-module.git?ref=master"
  table_name        = "test-table"
  hash_key          = "id"
  hash_key_type     = "S"
  range_key         = "timestamp"
  range_key_type    = "N"
  billing_mode      = "PAY_PER_REQUEST"
  ttl_enabled       = true
  ttl_attribute_name = "ttl"
  tags = {
    Environment = "Test"
  }
}

output "table_arn" {
  value = module.dynamodb_table.table_arn
}