# modules/tenant_iam_roles/main.tf

variable "project_id" {
  type        = string
  description = "The GCP project ID where the custom roles will be created."
}

# 1. Gemini Console Viewer: The "Observability" Role
resource "google_project_iam_custom_role" "gemini_console_viewer" {
  project     = var.project_id
  role_id     = "GeminiConsoleViewer"
  title       = "Gemini Console Viewer"
  description = "Functional read-only dashboard access for monitoring agent health and logs."
  permissions = [
    "resourcemanager.projects.get",
    "serviceusage.services.list",
    "run.services.list",
    "run.services.get",
    "run.locations.list",
    "run.revisions.list",
    "logging.logEntries.list",
    "monitoring.dashboards.list",
    "monitoring.timeSeries.list"
  ]
}

# 2. Gemini Data Steward: The "RAG" Role
resource "google_project_iam_custom_role" "gemini_data_steward" {
  project     = var.project_id
  role_id     = "GeminiDataSteward"
  title       = "Gemini Data Steward"
  description = "Access to BigQuery and GCS for managing tenant-specific RAG data."
  permissions = [
    "bigquery.datasets.get",
    "bigquery.tables.list",
    "bigquery.tables.getData",
    "storage.buckets.list",
    "storage.objects.list",
    "storage.objects.get"
  ]
}

# 3. Gemini Agent Builder: The "Developer" Role
resource "google_project_iam_custom_role" "gemini_agent_builder" {
  project     = var.project_id
  role_id     = "GeminiAgentBuilder"
  title       = "Gemini Agent Builder"
  description = "Deploy and manage Cloud Run services; blocked from IAM changes."
  permissions = [
    "run.services.create",
    "run.services.get",
    "run.services.list",
    "run.services.update",
    "run.services.delete",
    "run.configurations.get",
    "run.revisions.list"
  ]
}

# 4. Gemini App User: The "End User" Role
resource "google_project_iam_custom_role" "gemini_app_user" {
  project     = var.project_id
  role_id     = "GeminiAppUser"
  title       = "Gemini App User"
  description = "Allows invoking the Cloud Run agent service."
  permissions = ["run.routes.invoke"]
}
