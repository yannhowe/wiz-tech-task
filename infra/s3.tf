resource "aws_s3_bucket" "wiz-tech-task-mongodb-bucket" {
  bucket = "wiz-tech-task-mongodb-bucket"
  tags = {
    Name = "wiz-technical-task-mongodb-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "wiz-tech-task-mongodb-bucket" {
  bucket = aws_s3_bucket.wiz-tech-task-mongodb-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "wiz-tech-task-mongodb-bucket-policy" {
  bucket = aws_s3_bucket.wiz-tech-task-mongodb-bucket.id
  policy = data.aws_iam_policy_document.wiz-tech-task-mongodb-bucket-policy.json

  depends_on = [
    data.aws_iam_policy_document.wiz-tech-task-mongodb-bucket-policy,
    aws_s3_bucket.wiz-tech-task-mongodb-bucket,
    aws_s3_bucket_public_access_block.wiz-tech-task-mongodb-bucket
  ]
}

data "aws_iam_policy_document" "wiz-tech-task-mongodb-bucket-policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.wiz-tech-task-mongodb-bucket.arn,
      "${aws_s3_bucket.wiz-tech-task-mongodb-bucket.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "wiz-tech-task-mongodb-bucket-policy-write" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject",
      "s3:PutBucketTagging"
    ]

    resources = [
      aws_s3_bucket.wiz-tech-task-mongodb-bucket.arn,
      "${aws_s3_bucket.wiz-tech-task-mongodb-bucket.arn}/*",
    ]
  }
}

output "s3-bucket-uri" {
  value = "http://${aws_s3_bucket.wiz-tech-task-mongodb-bucket.id}.s3.amazonaws.com/"
}
