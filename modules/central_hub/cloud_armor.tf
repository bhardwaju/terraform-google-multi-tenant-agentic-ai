# modules/central_hub/cloud_armor.tf

resource "google_compute_security_policy" "security_policy" {
  name    = "central-hub-flexible-policy"
  project = var.hub_project_id

  # --- LEVEL 1: IP ALLOWLIST (Optional Internal-Only Lock) ---
  # TO ENABLE INTERNAL-ONLY: Set var.trusted_corporate_ip_ranges.
  # TO KEEP PUBLIC: Leave the variable empty or ignore this rule.
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

  # --- LEVEL 2: SECURITY SCANNING (Applied to ALL allowed traffic) ---

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
    rule_id  = "xss_protection"
    action   = "deny(403)"
    priority = "1010"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('xss-stable')"
      }
    }
    description = "WAF: Block XSS"
  }

  # --- LEVEL 3: GLOBAL ACCESS CONTROL ---

  # SCENARIO A: PUBLIC ACCESS (Default)
  # Use this rule to allow the general public while still filtering via WAF above.
  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default Allow: Use for Public-Facing applications"
  }

  /* # SCENARIO B: INTERNAL-ONLY (The "First-Packet-Deny")
  # TO ENABLE: Uncomment this rule and DELETE the "Default Allow" rule above.
  # This will drop all traffic not explicitly allowed in Rule 100.
  
  rule {
    action   = "deny(403)"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default Deny: Use for Internal-Only/VPN-only applications"
  }
  */
}
