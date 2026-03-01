resource "google_iap_brand" "project_brand" {
  project           = var.hub_project_id
  support_email     = "admin@example.com" # Placeholder
  application_title = "Multi-Tenant AI Portal"
}

resource "google_iap_client" "project_client" {
  display_name = "Frontend Portal Client"
  brand        = google_iap_brand.project_brand.name
}
