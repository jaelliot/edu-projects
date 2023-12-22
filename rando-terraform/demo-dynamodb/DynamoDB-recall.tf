resource "aws_dynamodb_table" "pet_recalls" {
  name           = "PetRecalls"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "unique_aer_id_number"

  # DynamoDB server-side encryption
  server_side_encryption {
    enabled = true
  }

  # Attributes definitions
  attribute {
    name = "unique_aer_id_number"
    type = "S"
  }
  attribute {
    name = "RecallDate"
    type = "S"
  }
  attribute {
    name = "ManufacturerName"
    type = "S"
  }

  # Global Secondary Index for Recall Date
  global_secondary_index {
    name               = "DateIndex"
    hash_key           = "RecallDate"
    projection_type    = "ALL"
  }

  # Global Secondary Index for Manufacturer Name
  global_secondary_index {
    name               = "ManufacturerIndex"
    hash_key           = "ManufacturerName"
    projection_type    = "ALL"
  }

  # Tags for easy identification and management
  tags = {
    Name = "PetRecalls"
    Project = "PetRecallsApp"
    Purpose = "Store recall information for pet products"
    Environment = "Sandbox"
    ManagedBy = "Terraform"
  }
}
