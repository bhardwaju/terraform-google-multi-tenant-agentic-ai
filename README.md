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

Information Gathering: Collect these IDs from your Console:

Organization ID (12-digit number)

Billing Account ID (e.g., 012345-567890-ABCDEF)

Folder ID (Where spoke projects will be created)

3. Self-Deployment Instructions
Step A: Clone and Initialize
Bash
git clone <your-repo-url>
cd terraform-google-multi-tenant-agentic-ai
terraform init
Step B: Configure Variables
Copy the example variable file and fill in your specific environment details:

Bash
cp terraform.tfvars.example terraform.tfvars
CRUCIAL: You must provide the Project Numbers (Numerical IDs) for the Hub and Spokes in terraform.tfvars. PAB and VPC-SC policies do not support String IDs for resource attachment.

Step C: Choose Your Connectivity Mode
In terraform.tfvars, configure trusted_corporate_ip_ranges:

For Public Access: Leave as [].

For Internal-Only: Add your VPN/Office IP ranges (e.g., ["35.2.3.4/32"]).

Step D: Deploy
Bash
terraform plan   # Review the 20+ resources
terraform apply  # Confirm with 'yes'
🚀 4. Step-by-Step Deployment Guide
Phase 1: Environment Preparation
Enable Required APIs in your seed/utility project:

Bash
gcloud services enable cloudresourcemanager.googleapis.com \
                       serviceusage.googleapis.com \
                       accesscontextmanager.googleapis.com \
                       billingbudgets.googleapis.com
Create an Access Policy (If one doesn't exist):

Bash
gcloud access-context-manager policies create \
  --organization=YOUR_ORG_ID --title="Org Policy"
Phase 2: Configuration
Edit terraform.tfvars: Use vi or nano to input your IDs.

Find Project Numbers:

Bash
gcloud projects describe YOUR_PROJECT_ID --format="value(projectNumber)"
Phase 3: Execution
Plan: terraform plan -out=platform.tfplan

Apply: terraform apply "platform.tfplan"

Phase 4: Post-Deployment Verification
Verify Outer Wall (VPC-SC):

Bash
gcloud access-context-manager perimeters list --policy=YOUR_ACCESS_POLICY_ID
Verify Inner Handcuffs (PAB):

Navigate to IAM & Admin > Principal Access Boundaries.

Check that mkt-isolation-policy is bound to the Marketing Agent's Service Account.

5. Security & Compliance Notes
Least Privilege: Manually bind the custom roles (GeminiAgentBuilder, etc.) to users in main.tf.

State Management: Use a secure GCS bucket for terraform.tfstate.

Secrets: Move all sensitive strings to Google Cloud Secret Manager.

6. Impact & Reporting
Revenue Attribution: Project IDs are exported for billing mapping.

Security Audit: Perimeter names and PAB bindings are exported for compliance reviews.
