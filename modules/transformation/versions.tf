terraform {
  required_version = ">= 1.0" # Specify a minimum Terraform version

  required_providers {
    keboola = {
      source  = "keboola/keboola"
      version = ">= 0.3.2" # Specify a suitable version constraint for the Keboola provider
    }
  }
} 