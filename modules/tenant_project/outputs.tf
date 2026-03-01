# modules/tenant_project/outputs.tf

output "project_id" {
  value = google_project.tenant.project_id
}

output "agent_url" {
  value = google_cloud_run_v2_service.agent.uri
}
