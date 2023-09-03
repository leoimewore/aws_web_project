resource "aws_s3_bucket" "onebucket-vpc" {
   bucket = "connect-with-vpc-endpoint"

  
   tags = {
     Name = "Bucket1"
     Environment = "Test"
   }
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.onebucket-vpc.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [aws_s3_bucket_ownership_controls.example]

  bucket = aws_s3_bucket.onebucket-vpc.id
  acl    = "private"
}