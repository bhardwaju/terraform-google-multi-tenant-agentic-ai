# modules/tenant_project/variables.tf

variable "project_id" { type = string }
variable "tenant_name" { type = string }
variable "billing_account" { type = string }
variable "folder_id" { type = string }
variable "region" { 
  type    = string
  default = "us-central1"
}

variable "org_id" {
  description = "The Google Cloud Organization ID"
  type        = string
}

variable "tenant_id" {
  description = "Short identifier for the tenant (e.g., 'mkt', 'hr') used for resource naming"
  type        = string
}

variable "project_number" {
  description = "The numerical project number (required for PAB resource paths)"
  type        = string
}
