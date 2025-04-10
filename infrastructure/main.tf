provider "aws" {
  region = "us-east-1" # Choose your preferred AWS region
}

# Choose a globally unique bucket name! Replace 'your-unique-bucket-name-cicd-demo'
variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
  default     = "my_bucket" # <--- CHANGE THIS TO BE GLOBALLY UNIQUE
}

resource "aws_s3_bucket" "site_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_website_configuration" "site_website" {
  bucket = aws_s3_bucket.site_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html" # Optional: you'd need to create and upload an error.html too
  }
}

# Allow public read access to the bucket objects
resource "aws_s3_bucket_public_access_block" "site_public_access" {
  bucket = aws_s3_bucket.site_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "site_policy" {
  bucket = aws_s3_bucket.site_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::${aws_s3_bucket.site_bucket.id}/*"
      },
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.site_public_access]
}

# Output the website endpoint URL
output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.site_website.website_endpoint
  description = "The S3 static website endpoint URL"
}