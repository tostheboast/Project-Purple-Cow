terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~>3.27"
		}
	}

	required_version = ">=0.14.9"
	
}

provider "aws" {
	region = var.aws_region
	access_key = var.aws_access_key_id
	secret_key = var.access_key_secret	
}

module "lambda" {
	source = "./modules/lambda"
	
}
