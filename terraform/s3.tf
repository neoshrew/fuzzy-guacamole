resource aws_s3_bucket this {
  bucket = "${var.global_prefix}-${local.project_prefix}-bucket"
  acl    = "private"

  tags = {
    Name = "${local.project_prefix} Bucket"
  }
}

resource aws_s3_bucket_public_access_block bucket {
  bucket                  = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
