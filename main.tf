# root main.tf

# 1. The Shared Routing Hub (Shared Services)
module "routing_hub" {
  source         = "./modules/central_hub"
  hub_project_id = var.hub_project_id
  region         = var.region
}

# 2. Tenant Spoke Instance: Marketing
module "tenant_marketing" {
  source          = "./modules/tenant_project"
  tenant_name     = "marketing"
  project_id      = "mkt-${var.tenant_id_suffix}"
  folder_id       = var.folder_id
  billing_account = var.billing_account
  region          = var.region
}

# 3. Tenant Spoke Instance: HR
module "tenant_hr" {
  source          = "./modules/tenant_project"
  tenant_name     = "hr"
  project_id      = "hr-${var.tenant_id_suffix}"
  folder_id       = var.folder_id
  billing_account = var.billing_account
  region          = var.region
}
