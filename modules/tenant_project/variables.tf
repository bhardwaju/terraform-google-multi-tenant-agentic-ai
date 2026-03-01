# modules/tenant_project/variables.tf

variable "project_id" { type = string }
variable "tenant_name" { type = string }
variable "billing_account" { type = string }
variable "folder_id" { type = string }
variable "region" { 
  type    = string
  default = "us-central1"
}
