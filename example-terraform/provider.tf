terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.71.0"
    }
    artifactory = {
      source = "jfrog/artifactory"
      version = "2.6.24"
    }
  }
}