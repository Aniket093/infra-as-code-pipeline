terraform {
  backend "s3" {
    bucket         = "my-tf-state-bucket"
    key            = "prod/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "tf-state-lock"
    encrypt        = true
  }
}
