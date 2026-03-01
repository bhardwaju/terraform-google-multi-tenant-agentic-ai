# root variables.tf

variable "hub_project_id" {
  type        = string
  description = "Project ID for the central routing hub."
}

variable "billing_account" {
  type        = string
  description = "Billing account to associate with all projects."
}

variable "folder_id" {
  type        = string
  description = "Folder ID where tenant projects will be created."
}

variable "tenant_id_suffix" {
  type        = string
  description = "A unique suffix for project IDs to ensure global uniqueness."
}

variable "region" {
  type    = string
  default = "us-central1"
}

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0"
    }
  }
}
