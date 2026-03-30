# modules/tenant_project/storage.tf

resource "google_storage_bucket" "rag_bucket" {
  project                     = google_project.tenant.project_id
  name                        = "${google_project.tenant.project_id}-rag-data"
  location                    = var.region
  uniform_bucket_level_access = true

  # Lifecycle Rule 1: Delete older documents based on the retention variable
  lifecycle_rule {
    condition {
      age = var.rag_bucket_retention_days
    }
    action {
      type = "Delete"
    }
  }

  # Lifecycle Rule 2: Clean up incomplete multipart uploads (Best Practice for frequent writes)
  lifecycle_rule {
    condition {
      age = 7 # Abort uploads that have been stalled for 7 days
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

resource "google_bigquery_dataset" "rag_dataset" {
  project    = google_project.tenant.project_id
  dataset_id = "rag_dataset"
  location   = var.region
}