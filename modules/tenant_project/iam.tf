# 1. Define the Boundary Policy for the specific tenant (e.g., Marketing)
resource "google_iam_principal_access_boundary_policy" "tenant_isolation" {
  organization   = var.org_id
  location       = "global"
  pab_policy_id  = "${var.tenant_id}-isolation-policy"
  display_name   = "Isolation Policy for ${var.tenant_name}"
  
  rules {
    description = "Restrict ${var.tenant_name} Agent identity to its own project resources"
    effect      = "ALLOW"
    # This restricts the identity to ONLY its own Project Number
    resources   = ["cloudresourcemanager.googleapis.com/projects/${var.project_number}"]
  }
}

# 2. Bind the Agent's Service Account to that Boundary
resource "google_iam_principal_access_boundary_policy_binding" "agent_pab_binding" {
  organization = var.org_id
  location     = "global"
  pab_policy   = google_iam_principal_access_boundary_policy.tenant_isolation.id
  # Uses the Service Account created earlier in this module
  principal    = "serviceAccount:${google_service_account.agent_runtime_sa.email}"
}
