terraform {
 backend "gcs" {
   bucket  = "${var.project_id}-tf-bucket"
   prefix  = "terraform/state"
 }
}