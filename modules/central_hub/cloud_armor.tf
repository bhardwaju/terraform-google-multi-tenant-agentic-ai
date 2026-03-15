# modules/central_hub/cloud_armor.tf

resource "google_compute_security_policy" "security_policy" {
  name    = "central-hub-hardened-policy"
  project = var.hub_project_id

  # =============================================================================
  # LEVEL 1: TRUSTED ACCESS (IP Allowlist)
  # =============================================================================
  # Only allows traffic from your corporate CIDR ranges defined in variables.
  rule {
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

  # =============================================================================
  # LEVEL 2: THREAT INTELLIGENCE & BOT PROTECTION
  # =============================================================================
  # Blocks known malicious actors, botnets, and scanners before they hit the WAF.
  rule {
    action   = "deny(403)"
    priority = "500"
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('botman-stable')"
      }
    }
    description = "WAF: Block known botnets and scanners"
  }

  # =============================================================================
  # LEVEL 3: WAF PAYLOAD INSPECTION (SQLi & XSS)
  # =============================================================================
  
  # Rule: Block SQL Injection (SQLi)
  rule {
    action   = "deny(403)"
    priority = "1000"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('sqli-stable')"
      }
    }
    description = "WAF: Block SQL Injection"
  }

  # Rule: Block Cross-Site Scripting (XSS)
  rule {
    action   = "deny(403)"
    priority = "1010"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('xss-stable')"
      }
    }
    description = "WAF: Block XSS"
  }

  # =============================================================================
  # LEVEL 4: GLOBAL DEFAULT (Hard Isolation Enforcement)
  # =============================================================================
  
  # DEFAULT DENY: This ensures that any traffic NOT originating from the 
  # trusted_corporate_ip_ranges is dropped at the edge. 
  # This aligns with the "Hard Isolation" strategy.
  rule {
    action   = "deny(403)"
    priority = "2147483647" # Lowest priority (Default Rule)
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default Deny: All non-allowlisted traffic is blocked"
  }
}
