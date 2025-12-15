terraform {
  backend "gcs" {
    bucket = "REPLACE_WITH_BUCKET_NAME"
    prefix = "terraform/dev"
  }
}
