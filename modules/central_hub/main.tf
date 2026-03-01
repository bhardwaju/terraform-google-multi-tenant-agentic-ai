resource "google_cloud_run_v2_service" "frontend_portal" {
  name     = "frontend-portal"
  location = var.region
  project  = var.hub_project_id

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }
}
