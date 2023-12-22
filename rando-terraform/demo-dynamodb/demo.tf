provider "aws" {
    region = "us-west-1"
}

resource "aws_dynamodb_table" "Table" {
    name = "Document"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "Data"

attribute {
    name = "Data"
    type = "S"
}

}

resource "aws_dynamodb_table_item" "item" {
    table_name = aws_dynamodb_table.Table.name
    hash_key = aws_dynamodb_table.Table.hash_key

    item = <<ITEM
    {
    "Data": {"s":"AWS"},
    "Age": {"N":"233"}
    }
    ITEM
}
