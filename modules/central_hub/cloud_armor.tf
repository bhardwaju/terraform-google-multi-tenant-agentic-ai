# modules/central_hub/cloud_armor.tf

locals {
  # Grouping WAF and Threat Intelligence rules to keep the code DRY
  waf_expression_rules = {
    bot-protection = {
      action      = "deny(403)"
      priority    = 500
      expression  = "evaluatePreconfiguredExpr('botman-stable')"
      description = "WAF: Block known botnets and scanners"
    }
    sqli-protection = {
      action      = "deny(403)"
      priority    = 1000
      expression  = "evaluatePreconfiguredWaf('sqli-stable', {'sensitivity': 1})"
      description = "WAF: Block SQL Injection"
    }
    xss-protection = {
      action      = "deny(403)"
      priority    = 1010
      expression  = "evaluatePreconfiguredWaf('xss-stable', {'sensitivity': 1})"
      description = "WAF: Block XSS"
    }
    # Future rules (like LFI, RCE, etc.) can simply be added to this map
  }
}

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
  # LEVEL 2 & 3: WAF PAYLOAD INSPECTION & THREAT INTEL (Dynamic Block)
  # =============================================================================
  # Iterates over the local.waf_expression_rules map to generate rules dynamically.
  dynamic "rule" {
    for_each = local.waf_expression_rules
    content {
      action      = rule.value.action
      priority    = rule.value.priority
      description = rule.value.description
      match {
        expr {
          expression = rule.value.expression
        }
      }
    }
  }

  # =============================================================================
  # LEVEL 4: GLOBAL DEFAULT (Hard Isolation Enforcement)
  # =============================================================================
  # DEFAULT DENY: This ensures that any traffic NOT originating from the 
  # trusted_corporate_ip_ranges is dropped at the edge. 
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