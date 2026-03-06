# root main.tf

# 1. The Shared Routing Hub (Centralized Security & Gateway)
module "routing_hub" {
  source                      = "./modules/central_hub"
  hub_project_id              = var.hub_project_id
  region                      = var.region
  # Passes the IP ranges to support the "Internal-Only" Cloud Armor toggle
  trusted_corporate_ip_ranges = var.trusted_corporate_ip_ranges
}

# 2. Tenant Spoke Instance: Marketing
module "tenant_marketing" {
  source          = "./modules/tenant_project"
  tenant_name     = "marketing"
  tenant_id       = "mkt"
  project_id      = "mkt-${var.tenant_id_suffix}"
  project_number  = var.mkt_project_number # Required for Principal Access Boundaries
  folder_id       = var.folder_id
  billing_account = var.billing_account
  region          = var.region
  org_id          = var.org_id            # Required for PAB
}

# 3. Tenant Spoke Instance: HR
module "tenant_hr" {
  source          = "./modules/tenant_project"
  tenant_name     = "hr"
  tenant_id       = "hr"
  project_id      = "hr-${var.tenant_id_suffix}"
  project_number  = var.hr_project_number  # Required for PAB
  folder_id       = var.folder_id
  billing_account = var.billing_account
  region          = var.region
  org_id          = var.org_id             # Required for PAB
}

# 4. The Macro-Perimeter (VPC Service Controls)
# Wraps the Hub and all Spokes in one single organizational wall
resource "google_access_context_manager_service_perimeter" "platform_macro_perimeter" {
  parent = "accessPolicies/${var.access_policy_id}"
  name   = "accessPolicies/${var.access_policy_id}/servicePerimeters/agent_factory_boundary"
  title  = "Agent Factory Macro Perimeter"
  
  status {
    # Combine Hub and Spoke project numbers for the unified boundary
    resources = [
      "projects/${var.hub_project_number}",
      "projects/${var.mkt_project_number}",
      "projects/${var.hr_project_number}"
    ]

    restricted_services = [
      "storage.googleapis.com",
      "bigquery.googleapis.com",
      "aiplatform.googleapis.com",
      "discoveryengine.googleapis.com",
      "logging.googleapis.com"
    ]
  }
}
