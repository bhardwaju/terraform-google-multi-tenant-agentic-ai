# compliance.tf (Root Directory)

# =============================================================================
# SECURITY GUARDRAIL: IAM Resource Isolation Enforcement
# Validates that sensitive service roles are scoped to specific resources 
# rather than the project level to maintain Multi-Tenant Hard Isolation.
# =============================================================================

check "iam_resource_scoped_enforcement" {
  data "google_project_iam_policy" "tenant_check" {
    project = module.tenant_project.project_id 
  }

  assert {
    condition = !anytrue([
      for binding in data.google_project_iam_policy.tenant_check.bindings : 
      binding.role == "roles/run.invoker"
    ])
    
    error_message = <<EOT
      Access Control Violation: 'roles/run.invoker' detected at the Project level.
      This violates the Multi-Tenant Isolation Architecture. 
      All service invocation permissions must be scoped to specific Cloud Run 
      service resources in the tenant module.
    EOT
  }
}
