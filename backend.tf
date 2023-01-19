terraform {
 backend "gcs" {
   bucket  = "my-sample-app-375112-tf-bucket"
   prefix  = "terraform/state"
 }
}