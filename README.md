## Automated Deployment of a Containerised Web Application on Azure AKS with GitHub Actions, Terraform, HPA, Argo CD, Prometheus & Grafana

# Project Overview

This project delivers a fully automated, cloud-native deployment pipeline for a containerised web application on Azure Kubernetes Service (AKS). It leverages Terraform for infrastructure provisioning, GitHub Actions for CI/CD orchestration, and integrates Horizontal Pod Autoscaler (HPA) for dynamic scaling. Observability is achieved through Prometheus and Grafana, while Argo CD ensures GitOps-driven deployment fidelity. Sensitive credentials are securely managed using GitHub Secrets, and dynamic Terraform outputs facilitate seamless downstream integration.

This solution exemplifies modern DevSecOps, GitOps, and Site Reliability Engineering (SRE) principles, mapped to CPD, recruiter engagement, and statutory compliance.


# Prerequisites

Category	            Requirement	

Cloud Infrastructure	     Azure subscription with AKS enabled	
IaC Tooling	            Terraform CLI and Azure provider configuration	
CI/CD Platform	     GitHub repository with Actions enabled	
Kubernetes Resources	     Containerised web application (pre-built image)	
Secrets Management	     GitHub Secrets configured for SP credentials, kubeconfig, and tokens	
Monitoring Stack	     Helm charts for Prometheus, Grafana, kube-state-metrics, node-exporter	
GitOps Tooling	     Argo CD installed in AKS with GitHub repo linked	

# Implementation Steps

1. Provision AKS Infrastructure with Terraform

• Defined AKS cluster, node pools, networking, and RBAC policies.
• Enabled remote state backend for auditability.
• Exposed dynamic outputs (e.g., kubeconfig path, ingress IP) for GitHub Actions consumption.


2. Configure GitHub Actions for CI/CD

• Created multi-stage workflow:• Build and tag Docker image (pre-containerised).
• Apply Kubernetes manifests using Terraform outputs.
• Trigger Argo CD sync via CLI/API.


3. Secure Secrets with GitHub Secrets

• Stored service principal credentials, kubeconfig, and token securely.
• Referenced secrets in GitHub Actions using `${{ secrets.<NAME> }}` syntax.


4. Deploy GitOps Workflow with Argo CD

• Installed Argo CD via Helm in a dedicated namespace.
• Linked GitHub repo as source of truth.
• Enabled auto-sync and rollback for declarative deployment fidelity.


5. Integrate Horizontal Pod Autoscaler (HPA)

• Defined HPA in deployment manifest using CPU/memory thresholds.
• Validated scaling behaviour under simulated load.


6. Implement Observability with Prometheus & Grafana

• Deployed Prometheus stack via Helm.
• Configured Grafana dashboards for:• Pod health
• HPA metrics
• Cluster resource usage

• Enabled Prometheus alerting rules for proactive incident response.


# Best Practices Adopted

• GitOps Compliance: Git as the single source of truth for deployments.
• Immutable Infrastructure: Terraform ensures reproducibility and version control.
• Secrets Hygiene: No hardcoded credentials; all secrets managed via GitHub Secrets.
• Modular IaC Design: Terraform modules for scalability and reuse.
• Observability First: Metrics and dashboards implemented before production rollout.
• Auto-healing & Drift Detection: Argo CD ensures live state fidelity.
• Elastic Scaling: HPA enables cost-effective performance tuning.

# Technical Rationale & Justification

Component	              Rationale	

Terraform	       Declarative, version-controlled provisioning aligned with IaC principles.	
GitHub Actions	Native CI/CD integration with GitHub, enabling seamless automation.	
Argo CD	       GitOps-driven deployment ensures traceability, rollback, and compliance.	
HPA	              Enables responsive scaling based on real-time metrics.	
Prometheus	       Robust metrics collection and alerting for SRE-grade observability.	
Grafana	       Intuitive dashboards for stakeholder visibility and performance insights.	
GitHub Secrets	Secure credential management aligned with DevSecOps standards.	

# Benefits for Cloud-Native DevOps & SRE

• Zero-touch Deployment: From Git commit to live service with full automation.
• Scalability & Resilience: HPA ensures performance under load; Argo CD enables rollback.
• Observability & Alerting: Prometheus and Grafana provide real-time insights and proactive alerts.
• Security & Compliance: GitHub Secrets and GitOps workflows ensure audit-ready posture.
• Developer Empowerment: Self-service deployment and feedback loops accelerate delivery.
• Cost Efficiency: Elastic scaling and resource monitoring reduce overprovisioning.


# Next Steps

DevSecOps Integration within the Workflow at different Layers would be considered including: 

1️⃣ Code & Dependency Security (before build)

Objective: Detect vulnerabilities, secrets, or policy violations before provisioning or deployment.
🔹 Static Application Security Testing (SAST)
🔹 Secret Scanning / Credential Leakage
Check for accidentally committed secrets.

2️⃣ Infrastructure-as-Code (Terraform) Security

Objective: Prevent insecure infrastructure definitions before they reach Azure.
🔹 Static IaC Scan (Terraform)
Use Checkov or tfsec to enforce cloud security best practices.
This checks for publicly exposed AKS or storage accounts, missing encryption, insecure network rules & lack of RBAC / logging

3️⃣ Container Image Security

Objective: Scan your Docker image for OS/package vulnerabilities before deployment.
🔹 Container Vulnerability Scan
     Integrate Aqua Trivy (free and popular) before pushing or before deploying to AKS.

4️⃣ Dependency & Supply-Chain Security

Objective: Secure your build environment and dependencies.
•	Enable Dependabot for automatic dependency updates:
•	Usage of signed commits and enable branch protection rules (required reviews, CI checks, etc.)

5️⃣ Runtime & Kubernetes Security

Objective: Validate your AKS manifests and cluster configuration.
🔹 Kubernetes Manifest Scanning
   Use kube-linter or kubescape before kubectl apply to flag containers running as root, missing resource limits, unencrypted secrets & insecure host paths
🔹 Post-Deployment Checks (Optional)
        After deployment, integration of kubescape or OPA Gatekeeper for runtime policy compliance and Azure Defender for Kubernetes (native AKS integration)

6️⃣ Compliance & Reporting

Generate a summary or artifact of all security checks.
Optionally, integrate results into GitHub Security Dashboard (with CodeQL + Dependabot).



