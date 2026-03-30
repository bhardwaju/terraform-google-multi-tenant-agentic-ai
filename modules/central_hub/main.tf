# In your variables.tf:

variable "frontend_image_name" {
  description = "The base name/URL of the container image for the frontend portal."
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello" 
}

variable "frontend_image_tag" {
  description = "The specific tag or version of the container image to deploy."
  type        = string
  default     = "latest" 
}

# ----------------------------------------------------------------------

# In your locals.tf (or at the top of your resource file):

locals {
  # Concatenates the image name and tag dynamically
  frontend_container_image = "${var.frontend_image_name}:${var.frontend_image_tag}"
}

# ----------------------------------------------------------------------

# In your main resource file:

resource "google_cloud_run_v2_service" "frontend_portal" {
  name     = "frontend-portal"
  location = var.region
  project  = var.hub_project_id

  template {
    containers {
      image = local.frontend_container_image
    }
  }
}