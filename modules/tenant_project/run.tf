# modules/tenant_project/run.tf

# 1. The Service Account the Agent uses to talk to Vertex AI
resource "google_service_account" "agent_sa" {
  project      = google_project.tenant.project_id
  account_id   = "agent-runtime-sa"
  display_name = "Agent Runtime Service Account"
}

# 2. The Cloud Run Service (The Agent itself)
resource "google_cloud_run_v2_service" "agent" {
  name     = "${var.tenant_name}-agent"
  location = var.region
  project  = google_project.tenant.project_id

  template {
    service_account = google_service_account.agent_sa.email
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello" # Placeholder for your ADK image
    }
  }

  # Ensure APIs are ready before trying to deploy
  depends_on = [google_project_service.apis]
}


# MCP Server - The "Tools" provider for the Agent
resource "google_cloud_run_v2_service" "mcp_server" {
  name     = "${var.tenant_name}-mcp-server"
  location = var.region
  project  = google_project.tenant.project_id

  template {
    service_account = google_service_account.agent_sa.email
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello" # Placeholder for MCP Server Image
      env {
        name  = "DATASET_ID"
        value = google_bigquery_dataset.rag_dataset.dataset_id
      }
    }
  }
  depends_on = [google_project_service.apis]
}
