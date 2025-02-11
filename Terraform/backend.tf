terraform {
  backend "s3" {
    bucket = "mostafas"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}