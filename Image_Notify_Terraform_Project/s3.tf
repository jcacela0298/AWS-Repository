# Resource to create a globally unique bucket name
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
}


# Define an S3 bucket with the globally unique bucket name
resource "aws_s3_bucket" "my_bucket" {
  bucket = "image-upload-bucket-${lower(random_string.bucket_suffix.result)}"
  acl    = "private"



  # Define Tags
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }



  # Define server side encryption
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"  # Specify the encryption algorithm (e.g., AES256 for SSE-S3)
      }
      bucket_key_enabled = true
    }
  }
}



# Enable Versioning 
# Note that we don't define the acl part here because we 
# already defined it at the very top. (You can define it here or above)
resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.my_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Define Amazon EventBridge to receive event notifications
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket      = aws_s3_bucket.my_bucket.id
  eventbridge = true
 }