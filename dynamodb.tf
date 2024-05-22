resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "url-shortener-table2"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "short_id"

 
  attribute {
    name = "short_id"
    type = "S"
  }

  tags = local.tags
}