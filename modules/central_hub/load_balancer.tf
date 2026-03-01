resource "google_compute_backend_service" "frontend_backend" {
  project               = var.hub_project_id
  name                  = "frontend-portal-backend"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTP"
}

resource "google_compute_backend_service" "frontend_backend" {
  project               = var.hub_project_id
  name                  = "frontend-portal-backend"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTP"
  
  # THIS IS THE LINK:
  security_policy = google_compute_security_policy.security_policy.self_link
}
