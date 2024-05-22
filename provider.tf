terraform {

  cloud {
    organization = "steve_lane"

    workspaces {
      name = "url-shortener"
    }
  }



  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.37.0"
    }
  }

}

provider "aws" {
  region = var.region
}
