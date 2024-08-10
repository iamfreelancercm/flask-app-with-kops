
# Define the S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "waseem-flask-s3"  # Replace with a unique bucket name
  acl    = "private"  # Set bucket ACL to private by default

  tags = {
    Name        = "my-bucket"
    Environment = "dev"
  }
}

# Define the S3 bucket lifecycle policy to transition objects to S3 Glacier
resource "aws_s3_bucket_lifecycle_configuration" "my_bucket_lifecycle" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    id     = "transition-to-glacier"
    status = "Enabled"

    filter {
      prefix = ""  # Apply the rule to all objects in the bucket
    }

    transitions {
      days          = 30  # Number of days after which to transition to Glacier
      storage_class  = "GLACIER"  # Transition to S3 Glacier
    }

    # Uncomment the following to transition to Glacier Deep Archive instead
    # transitions {
    #   days          = 30  # Number of days after which to transition to Glacier Deep Archive
    #   storage_class  = "DEEP_ARCHIVE"  # Transition to S3 Glacier Deep Archive
    # }

    # Uncomment the following to delete objects after a certain number of days
    # expiration {
    #   days = 365  # Number of days after which objects should be deleted
    # }
  }
}

# Output the bucket name
output "bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
}
