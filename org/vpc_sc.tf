# org/vpc_sc.tf

resource "google_access_context_manager_service_perimeter" "tenant_perimeter" {
  parent = "accessPolicies/${var.access_policy_id}"
  name   = "accessPolicies/${var.access_policy_id}/servicePerimeters/tenant_ai_perimeter"
  title  = "Agentic AI Tenant Perimeter"
  
  # Set to true for "Dry Run" mode to test without blocking traffic
  use_explicit_dry_run_spec = true 

  status {
    # Include the project numbers for Marketing and HR
    resources = [
      "projects/${var.marketing_project_number}",
      "projects/${var.hr_project_number}"
    ]

    # The "High Risk" services we want to lock down
    restricted_services = [
      "storage.googleapis.com",
      "bigquery.googleapis.com",
      "aiplatform.googleapis.com",
      "run.googleapis.com"
    ]

    # Ingress Policy: Allow the Central Hub to talk to the Spokes
    ingress_policies {
      ingress_from {
        identity_type = "ANY_IDENTITY"
        sources {
          project = "projects/${var.hub_project_number}"
        }
      }
      ingress_to {
        resources = ["*"]
        operations {
          service_name = "*"
          method_selectors { method = "*" }
        }
      }
    }
  }
}
