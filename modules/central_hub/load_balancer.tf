resource "google_compute_backend_service" "frontend_backend" {
  project               = var.hub_project_id
  name                  = "frontend-portal-backend"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTP"
}
