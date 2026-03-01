# modules/central_hub/cloud_armor.tf

resource "google_compute_security_policy" "security_policy" {
  name    = "central-hub-waf-policy"
  project = var.hub_project_id

  # Rule 1: Block SQL Injection (SQLi)
  rule {
    action   = "deny(403)"
    priority = "1000"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('sqli-stable')"
      }
    }
    description = "Block SQL Injection attacks"
  }

  # Rule 2: Block Cross-Site Scripting (XSS)
  rule {
    action   = "deny(403)"
    priority = "1010"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('xss-stable')"
      }
    }
    description = "Block XSS attacks"
  }

  # Default Rule: Allow everyone else
  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default allow rule"
  }
}
