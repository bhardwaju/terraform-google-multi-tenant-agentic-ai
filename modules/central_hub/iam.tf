# modules/central_hub/iam.tf

# =============================================================================
# HUB-TO-SPOKE CONNECTIVITY
# Allows the Central Load Balancer's Service Agent to invoke Cloud Run 
# services located within the isolated Tenant Projects.
# =============================================================================

resource "google_project_iam_member" "hub_invoker" {
  # Iterates through your marketing and HR project IDs
  for_each = toset([var.mkt_project_id, var.hr_project_id])
  
  project = each.value
  role    = "roles/run.invoker"
  
  # The Google-managed service account for the GCE/LB layer in the Hub
  member  = "serviceAccount:service-${var.hub_project_number}@gcp-sa-compute.iam.gserviceaccount.com"
}
