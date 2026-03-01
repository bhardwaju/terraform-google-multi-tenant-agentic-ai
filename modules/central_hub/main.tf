# modules/central_hub/main.tf

# 1. Global External Load Balancer IP
resource "google_compute_global_address" "lb_ip" {
  name    = "central-hub-lb-ip"
  project = var.hub_project_id
}

# 2. Cloud Armor Security Policy (WAF)
resource "google_compute_security_policy" "policy" {
  name    = "central-hub-armor-policy"
  project = var.hub_project_id

  rule {
    action   = "allow"
    priority = "1000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config { src_ip_ranges = ["*"] }
    }
    description = "Default allow with WAF protection"
  }
}

# 3. Frontend Portal (Cloud Run)
resource "google_cloud_run_v2_service" "frontend_portal" {
  name     = "frontend-portal"
  location = var.region
  project  = var.hub_project_id

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello" # Placeholder
    }
  }
}
