# modules/tenant_project/outputs.tf

output "project_id" {
  value = google_project.tenant.project_id
}

output "agent_url" {
  value = google_cloud_run_v2_service.agent.uri
}

# --- Added for Security & Impact Tracking ---
output "agent_service_account_email" {
  description = "The email of the isolated Service Account for this tenant agent"
  value       = google_service_account.agent_runtime_sa.email
}
