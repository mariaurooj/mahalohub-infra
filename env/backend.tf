terraform {
  backend "s3" {
    bucket  = "mahalohub" 
    key     = "terraform-backend"
    region  = "us-east-1"
  }
}
