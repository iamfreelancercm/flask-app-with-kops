terraform {
  backend "s3" {
    bucket         = "flask-waseem"
    key            = "terraform/state.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
