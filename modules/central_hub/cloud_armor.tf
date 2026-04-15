# modules/central_hub/cloud_armor.tf

resource "google_compute_security_policy" "security_policy" {
  name    = "central-hub-hardened-policy"
  project = var.hub_project_id

  # =============================================================================
  # LEVEL 1: TRUSTED ACCESS (IP Allowlist)
  # =============================================================================
  # Dynamically creates this rule ONLY if corporate IPs are actually provided.
  # This prevents an API error if the list is empty.
  dynamic "rule" {
    for_each = length(var.trusted_corporate_ip_ranges) > 0 ? [1] : []
    content {
      action   = "allow"
      priority = "100"
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = var.trusted_corporate_ip_ranges
        }
      }
      description = "Allow traffic from trusted corporate network"
    }
  }

  # ... (Keep your LEVEL 2 and LEVEL 3 dynamic WAF rules exactly as they are) ...

  # =============================================================================
  # LEVEL 4: GLOBAL DEFAULT (Hard Isolation Enforcement)
  # =============================================================================
  
  # Evaluates the enforce_edge_lockdown variable to toggle the edge perimeter.
  rule {
    # If true -> block all traffic (except allowlist). If false -> let it through to the WAF.
    action   = var.enforce_edge_lockdown ? "deny(403)" : "allow"
    priority = "2147483647" # Lowest priority (Default Rule)
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    
    # Dynamically updates the description based on the mode
    description = var.enforce_edge_lockdown ? "Default Deny: Internal-Only mode" : "Default Allow: Public mode"
  }
}