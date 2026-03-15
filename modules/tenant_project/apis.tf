# modules/tenant_project/apis.tf

resource "google_project_service" "apis" {
  project = google_project.tenant.project_id
  for_each = toset([
    "run.googleapis.com", 
    "aiplatform.googleapis.com",
    "bigquery.googleapis.com", 
    "storage.googleapis.com",
    "modelarmor.googleapis.com",
    "securitycenter.googleapis.com",
    "iamcredentials.googleapis.com",
    "serviceusage.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com"
  ])
  service            = each.key
  disable_on_destroy = false
}
