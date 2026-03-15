# modules/central_hub/variables.tf

variable "hub_project_id" { type = string }

variable "hub_project_number" {
  description = "The numerical project number of the Hub (used for the LB Service Agent)"
  type        = string
}

variable "region" { 
  type    = string
  default = "us-central1" 
}

# --- Tenant Project IDs (Required for the IAM Bridge) ---

variable "mkt_project_id" {
  description = "Project ID for the Marketing tenant"
  type        = string
}

variable "hr_project_id" {
  description = "Project ID for the HR tenant"
  type        = string
}

# --- Flexible Security Variables ---

variable "trusted_corporate_ip_ranges" {
  description = "List of public IP ranges (CIDR) for Internal-Only access."
  type        = list(string)
  default     = [] 
}

variable "enforce_edge_lockdown" {
  description = "Toggle to switch between Default Allow (Public) and Default Deny (Internal-Only)"
  type        = bool
  default     = false
}
