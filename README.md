Multi-Tenant Agentic AI Architecture (Terraform)
This repository provides the Well-Architected Framework for deploying a secure, multi-tenant Agentic AI platform on Google Cloud. It uses a Hub-and-Spoke model to provide centralized governance while maintaining "Hard Isolation" between business units (e.g., HR, Marketing, Finance).

1. Architecture Overview
The deployment automates a "Double-Lock" security strategy:

The Outer Wall (VPC Service Controls): A single Macro-Perimeter wraps the Hub and all Spoke projects to prevent data exfiltration to the public internet.

The Inner Handcuffs (Principal Access Boundaries): Every tenant agent is assigned a unique Service Account. A PAB Policy cryptographically restricts that identity to its own project, preventing lateral movement between tenants.

The Smart Gate (Cloud Armor): A flexible Edge Security policy that supports both Public-Facing (WAF protected) and Internal-Only (First-Packet-Deny) access modes.

2. Prerequisites
Before you begin, ensure you have the following:

Google Cloud Organization: You must have an Organization node (PABs and VPC-SC cannot be tested in a standalone project).

Permissions: You need roles/resourcemanager.projectCreator and roles/accesscontextmanager.policyAdmin at the Folder or Org level.

Information Gathering: Collect the following IDs from your Google Cloud Console:

Organization ID: (12-digit number)

Billing Account ID: (e.g., 012345-567890-ABCDEF)

Folder ID: The ID where Spoke projects will be created.

3. Self-Deployment Instructions
Follow these steps to deploy the architecture without assistance:

Step A: Clone and Initialize
Bash
git clone <repository-url>
cd terraform-google-multi-tenant-agentic-ai
terraform init
Step B: Configure Variables
Copy the example variable file and fill in your specific environment details:

Bash
cp terraform.tfvars.example terraform.tfvars
Crucial: You must provide the "Project Numbers" (Numerical IDs) for the Hub and Spokes in terraform.tfvars. PAB and VPC-SC policies do not support String IDs for resource attachment.

Step C: Choose Your Connectivity Mode
Inside terraform.tfvars, configure the trusted_corporate_ip_ranges:

For Public Access: Leave as []. Cloud Armor will allow all traffic but filter for SQLi/XSS attacks.

For Internal-Only: Add your VPN/Office IP ranges (e.g., ["35.2.3.4/32"]). Cloud Armor will drop all other traffic at the edge.

Step D: Deploy
Bash
terraform plan   # Review the 20+ resources being created
terraform apply  # Confirm with 'yes'
4. Post-Deployment: The "Second Lock" Verification
Once Terraform finishes, it will output the Agent Service Account Emails. To finalize the setup:

Data Permissions: Grant the Marketing Agent SA access to your specific BigQuery datasets within the Marketing project.

Identity Verification: Navigate to IAM > Principal Access Boundaries in the Console to verify that the Marketing Agent is restricted to its own project ID.

5. Security & Compliance Notes
Least Privilege: This code creates custom roles (GeminiAgentBuilder, etc.). You must manually bind these roles to your human users/groups in the main.tf.

State Management: For production, move your terraform.tfstate to a secure GCS bucket with Object Versioning enabled.

Secrets: All API keys or sensitive strings should be moved to Google Cloud Secret Manager; do not hardcode them in .tfvars.

6. Impact & Reporting (For Stakeholders)
The outputs.tf file generates a summary used for tracking:

Revenue Attribution: Project IDs are exported for mapping to Cloud Billing.

Security Audit: Perimeter names and PAB bindings are exported for compliance reviews.


🚀 Step-by-Step Deployment Guide
Follow these exact steps to stand up the Multi-Tenant Agentic AI Platform.

Phase 1: Environment Preparation
Select your Organization: Ensure you have the Organization ID and a Folder ID where the projects will reside.

Enable Required APIs: In your seed/utility project (where you run Terraform), enable the Service Usage and Access Context Manager APIs:

Bash
gcloud services enable cloudresourcemanager.googleapis.com \
                       serviceusage.googleapis.com \
                       accesscontextmanager.googleapis.com \
                       billingbudgets.googleapis.com
Create an Access Policy: (If one doesn't exist) VPC Service Controls require an Access Policy at the Org level:

Bash
gcloud access-context-manager policies create --organization=YOUR_ORG_ID --title="Org Policy"
Copy the assigned ID (a 12-digit number) for your variables.tf.

Phase 2: Configuration
Initialize Terraform:

Bash
terraform init
Create your Variables File:

Bash
cp terraform.tfvars.example terraform.tfvars
Edit terraform.tfvars: Use vi or nano to input your specific IDs.

Pro Tip: To find your Project Numbers for the Hub and Spokes, run:
gcloud projects describe YOUR_PROJECT_ID --format="value(projectNumber)"

Phase 3: Execution
Plan the Deployment:

Bash
terraform plan -out=platform.tfplan
Review the output. You should see 25+ resources being created, including 3 projects, 1 perimeter, and 2 PAB policies.

Apply the Changes:

Bash
terraform apply "platform.tfplan"
Phase 4: Post-Deployment Verification
Once the "Apply complete!" message appears, verify the "Double-Lock" is active:

Verify the Outer Wall (VPC-SC):

Bash
gcloud access-context-manager perimeters list --policy=YOUR_ACCESS_POLICY_ID
Verify the Inner Handcuffs (PAB):
Go to the Google Cloud Console: IAM & Admin > Principal Access Boundaries.
Check that the mkt-isolation-policy is correctly bound to the Marketing Agent's Service Account.

Phase 5: Connecting the Agents
Deploy your Code: Navigate to the tenant_marketing project and deploy your Cloud Run container:

Bash
gcloud run deploy marketing-agent --image=YOUR_IMAGE --project=mkt-PROD_ID
Test Access: Try to access a BigQuery dataset in the HR project using the Marketing Agent's identity. The request should be denied by the PAB policy, even if IAM roles were accidentally granted.
