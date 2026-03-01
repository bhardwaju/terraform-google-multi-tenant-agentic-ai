# modules/tenant_project/main.tf

# 1. The Isolated Project
resource "google_project" "tenant" {
  name            = "Tenant-${var.tenant_name}"
  project_id      = var.project_id
  folder_id       = var.folder_id
  billing_account = var.billing_account
}

# 2. Enabling APIs (Vertex AI, Cloud Run, etc.)
resource "google_project_service" "apis" {
  project  = google_project.tenant.project_id
  for_each = toset([
    "run.googleapis.com",
    "aiplatform.googleapis.com",
    "bigquery.googleapis.com",
    "storage.googleapis.com",
    "serviceusage.googleapis.com"
  ])
  service = each.key

  disable_on_destroy = false
}

# 3. Injecting the Custom Roles we verified
module "tenant_roles" {
  source     = "../tenant_iam_roles"
  project_id = google_project.tenant.project_id
}

# 4. Agent Runtime Service Account (The "Identity" for the Cloud Run code)
resource "google_service_account" "agent_sa" {
  project      = google_project.tenant.project_id
  account_id   = "agent-runtime-sa"
  display_name = "Agent Runtime Service Account"
}
