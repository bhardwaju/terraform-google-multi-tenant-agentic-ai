# modules/tenant_project/run.tf

resource "google_service_account" "agent_sa" {
  project      = google_project.tenant.project_id
  account_id   = "agent-runtime-sa"
  display_name = "Agent Runtime Service Account"
}

resource "google_cloud_run_v2_service" "agent" {
  name     = "${var.tenant_name}-agent"
  location = var.region
  project  = google_project.tenant.project_id
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    service_account = google_service_account.agent_sa.email
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello" 
      env {
        name  = "MODEL_ARMOR_TEMPLATE"
        value = google_model_armor_template.tenant_filter.id
      }
    }
  }
  depends_on = [google_project_service.apis]
}

resource "google_cloud_run_v2_service" "mcp_server" {
  name     = "${var.tenant_name}-mcp-server"
  location = var.region
  project  = google_project.tenant.project_id
  ingress  = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  template {
    service_account = google_service_account.agent_sa.email
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
      env {
        name  = "DATASET_ID"
        value = google_bigquery_dataset.rag_dataset.dataset_id
      }
    }
  }
  depends_on = [google_project_service.apis]
}
