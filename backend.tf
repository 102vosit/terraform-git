terraform {
  backend "s3" {
    bucket = "gogreen-team04"
    key    = "tstate/gogreen.tfstate"
    region = "us-east-1"
  }
}