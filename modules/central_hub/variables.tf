variable "hub_project_id" { type = string }
variable "region"         { type = string, default = "us-central1" }

# --- Flexible Security Variables ---

variable "trusted_corporate_ip_ranges" {
  description = "List of public IP ranges (CIDR) for Internal-Only access. Leave empty for Public-Facing mode."
  type        = list(string)
  default     = [] # Default to empty to support the "Public" scenario
}

variable "enforce_edge_lockdown" {
  description = "Toggle to switch between Default Allow (Public) and Default Deny (Internal-Only)"
  type        = bool
  default     = false
}
