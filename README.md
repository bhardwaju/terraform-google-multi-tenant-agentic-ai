# Terraform for Multi-Tenant Agentic AI Architecture

This repository contains the Terraform modules to deploy the foundational infrastructure for the **"Multi-tenant agentic AI system using ADK and Cloud Run"** reference architecture.

This code is intended to be a clear and illustrative template. It creates the core isolated tenant projects and custom IAM roles. To move this to a full production deployment, you will need to extend it with your organization-specific details, particularly around IAM bindings, network configurations, and VPC Service Control ingress/egress rules.

## Architecture Overview

This Terraform deployment will create:

1.  **Reusable Tenant Module:** A module (`modules/tenant_project`) that can be called repeatedly to stamp out new, isolated tenant environments.
2.  **For Each Tenant:**
    *   A dedicated Google Cloud Project.
    *   The four unique Custom IAM Roles (`GeminiConsoleViewer`, `GeminiDataSteward`, `GeminiAgentBuilder`, `GeminiAppUser`) *within the tenant project*.
    *   Required API services enabled.
    *   A dedicated service account for the agent runtime (`agent-runtime-sa`).
    *   Placeholder data stores (GCS Bucket, BigQuery Dataset) for RAG.
    *   A placeholder Cloud Run service for the ADK-based agent.
3.  **Example Central Hub:** A module (`modules/central_hub`) demonstrating a potential setup for the Frontend Portal with Load Balancing and IAP. This section requires significant adaptation for your specific network and application.
4.  **Example VPC Service Controls:** An example (`org/vpc_sc.tf`) of how to define a perimeter. This must be managed at the organization level and requires detailed ingress/egress rule configuration.

## How to Use This Template

1.  **Clone this repository.**
2.  **Configure your backend:** For production use, configure a [remote backend](https://www.terraform.io/language/settings/backends/gcs) (e.g., Google Cloud Storage) for your Terraform state. Add the configuration to a file like `backend.tf`.
3.  **Create a `terraform.tfvars` file:** Copy `terraform.tfvars.examples` to `terraform.tfvars` and populate it with your organization-specific values (e.g., billing account, folder IDs, domain names).
4.  **Review and Customize:** Carefully review the variables and resource configurations in the modules, especially in `modules/central_hub/` and `org/vpc_sc.tf`.
5.  **Run Terraform:**
    ```bash
    terraform init
    terraform plan
    terraform apply
    ```

## Next Steps for Production Deployment

This template provides the architectural foundation. To make it fully operational in a production environment, you must complete the following critical steps:

**1. Implement IAM Bindings (Highest Priority)**

This code creates the custom roles within each tenant project but does not assign them to any users or groups. You must bind your Google Groups or service accounts to the appropriate roles.

*   **Example:** To grant your marketing developers the "Builder" role on the marketing tenant project, add the following to your tenant instantiation (e.g., `tenant_deployments/tenant_marketing.tf`):

    ```terraform
    resource "google_project_iam_member" "marketing_builder_binding" {
      project = module.marketing_tenant.project_id
      # Reference the custom role ID from the module output
      role    = module.marketing_tenant.gemini_agent_builder_role_id
      member  = "group:<REDACTED_PII>" # Replace with your group
    }

    # Add similar bindings for other roles and groups
    ```
    *   *Note: You'll need to add outputs for the role IDs in the `modules/tenant_iam_roles/outputs.tf` and pass them up through the `modules/tenant_project/outputs.tf`.*

**2. Configure VPC Service Controls Perimeter Rules**

The example `org/vpc_sc.tf` file defines a perimeter but likely lacks the necessary ingress/egress rules. These rules are critical for function.

*   **Ingress Rules:**
    *   Allow the Frontend Portal's service account (from the Central Hub project) to call the Cloud Run agent services within the perimeter.
    *   Allow other necessary management and monitoring services.
*   **Egress Rules:**
    *   Allow tenant agents to reach required Google APIs (like Vertex AI, Logging, Monitoring).
    *   Restrict access to other services as per your security policy.

**3. Deploy and Configure the Frontend Portal Application**

Replace the placeholder image in the `central_hub` module (`us-docker.pkg.dev/cloudrun/container/hello`) with your actual frontend application. This application is responsible for:
*   Authenticating the user via the IAP-provided JWT header.
*   Mapping the user's identity/groups to their corresponding tenant.
*   Dynamically routing requests to the correct tenant's Cloud Run service URL. Consider using environment variables or a configuration service to manage tenant endpoints.

**4. Finalize Network Configuration**

Adapt the network configuration in the `modules/central_hub/` module to match your organization's networking standards. This might involve integrating with an existing Shared VPC, configuring firewall rules, and setting up private service connect.

**5. Secure Service Accounts**

Ensure the `agent-runtime-sa` in each tenant project is granted only the minimum necessary permissions to access tenant data stores (BigQuery, GCS) and Vertex AI endpoints.

**6. Cloud Armor Policies**

Define and apply appropriate Cloud Armor security policies to the Load Balancer in the `central_hub` project to protect the Frontend Portal.

**7. Monitoring and Logging**

While logs are collected, configure centralized metrics dashboards and alerts in the Central Governance Platform as needed.

## Security Considerations

*   **Least Privilege:** Always grant the minimum necessary permissions.
*   **Remote State:** Protect your Terraform state file, as it may contain sensitive information. Use a secure, access-controlled GCS bucket.
*   **Secrets:** Do not hardcode secrets. Use a secret manager like Google Cloud Secret Manager.
*   **Regular Audits:** Periodically review IAM permissions and VPC-SC configurations.






