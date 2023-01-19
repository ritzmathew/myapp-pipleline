terraform {
 backend "gcs" {
   bucket  = "my-sample-app-375112-tf-bucket"
   prefix  = "terraform/state"
   
   encryption_key = "RQVFmYP9tCzCipwP5Cr3skrisMQ0DMQTZhz4D2OEfuM="
 }
}