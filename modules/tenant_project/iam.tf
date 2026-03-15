# modules/tenant_project/iam.tf

# 1. Principal Access Boundary (PAB)
resource "google_iam_principal_access_boundary_policy" "tenant_isolation" {
  organization   = var.org_id
  location       = "global"
  pab_policy_id  = "${var.tenant_id}-isolation-policy"
  display_name   = "Isolation Policy for ${var.tenant_name}"
  
  rules {
    description = "Restrict ${var.tenant_name} Agent identity to its own project resources"
    effect      = "ALLOW"
    resources   = ["cloudresourcemanager.googleapis.com/projects/${var.project_number}"]
  }
}

resource "google_iam_principal_access_boundary_policy_binding" "agent_pab_binding" {
  organization = var.org_id
  location     = "global"
  pab_policy   = google_iam_principal_access_boundary_policy.tenant_isolation.id
  principal    = "serviceAccount:${google_service_account.agent_sa.email}"
}

# 2. Model Armor & SCC Roles
resource "google_project_iam_member" "model_armor_user" {
  project = google_project.tenant.project_id
  role    = "roles/modelarmor.user"
  member  = "serviceAccount:${google_service_account.agent_sa.email}"
}

resource "google_project_iam_member" "scc_admin" {
  project = google_project.tenant.project_id
  role    = "roles/securitycenter.admin"
  member  = "serviceAccount:${google_service_account.agent_sa.email}"
}

# 3. Resource-Level User IAM (Ensuring Hard Isolation for Cloud Run)
resource "google_cloud_run_v2_service_iam_member" "agent_builder" {
  project  = google_project.tenant.project_id
  location = var.region
  name     = google_cloud_run_v2_service.agent.name
  role     = "roles/run.developer"
  member   = "group:GeminiAgentBuilders@yourcompany.com"
}

resource "google_cloud_run_v2_service_iam_member" "agent_user" {
  project  = google_project.tenant.project_id
  location = var.region
  name     = google_cloud_run_v2_service.agent.name
  role     = "roles/run.invoker"
  member   = "group:GeminiAppUsers@yourcompany.com"
}
