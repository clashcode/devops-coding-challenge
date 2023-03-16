
# Storage bucket for the app
resource "aws_s3_bucket" "bucket" {
  bucket = "testapp-files"
}
