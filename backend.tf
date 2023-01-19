variable "bucket_name" {
  type        = string
  description = "The name of the Google Storage Bucket to create"
}

variable "storage_class" {
  type        = string
  description = "The storage class of the Storage Bucket to create"
}

resource "google_storage_bucket" "tf-bucket" {
  project       = var.project_id
  name          = var.bucket_name
  location      = var.region
  force_destroy = true
  storage_class = var.storage_class
  versioning {
    enabled = true
  }
}