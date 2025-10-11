# End-to-End Delivery of a Secure, Automated, and Scalable Containerized Solution on Azure AKS Using Terraform and GitHub Actions

## Project Overview

This project demonstrates the deployment of a **pre-built containerized web application** to a managed Kubernetes cluster on **Azure AKS**. The application image is hosted on DockerHub, and Kubernetes manifests handle the deployment and exposure via a LoadBalancer service.

Pre-requisites:
---------------
1. Azure Subscription with Contributor access
2. Existing AKS Cluster (provisioned via Terraform)
3. DockerHub account with the pre-built image pushed
   - IMAGE: oresky73/ghs-nginx-app42:latest
4. GitHub repository with Kubernetes manifests (AKS/deploy.yaml & AKS/service.yaml)
5. GitHub secrets:
   - AZURE_CREDENTIALS (Service Principal JSON)
   - DOCKERHUB_USERNAME
   - DOCKERHUB_TOKEN
6. kubectl installed locally (optional for manual verification)
7. Azure CLI installed locally (optional for manual verification)


**Key Features:**

* **Managed Kubernetes Cluster:** Provisioned and managed with Terraform.
* **Pre-Built Containerized Application:** Docker image already hosted on DockerHub for deployment.
* **Automated Deployment:** GitHub Actions handles Azure login, AKS credentials, and deployment to Kubernetes.
* **External Access:** LoadBalancer service exposes the application.
* **Node and Service Readiness Checks:** Workflow ensures AKS nodes are ready and LoadBalancer IP is assigned.

**Tech Stack:**

* Azure Kubernetes Service (AKS)
* Docker & DockerHub (pre-built image)
* Terraform (AKS provisioning)
* GitHub Actions (CI/CD pipeline)
* Kubernetes manifests (Deployment & Service)


## Project Structure


├── AKS/
│   ├── deploy.yaml         # Kubernetes Deployment manifest
│   └── service.yaml        # Kubernetes LoadBalancer Service manifest
├── INFRA/                  # Terraform infrastructure code
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── .github/workflows/
│   └── deploy.yml          # GitHub Actions workflow
├── README.md


## Deployment Flow

1. AKS cluster provisioned via Terraform (pre-existing).
2. GitHub Actions workflow logs into Azure and retrieves AKS credentials.
3. Workflow deploys the **pre-built containerized application** using Kubernetes manifests.
4. Workflow waits for nodes to be ready and LoadBalancer IP to be assigned.
5. Application is accessible via the LoadBalancer IP.

# Workflow Overview:
------------------
GitHub Push to main branch
          │
          ▼
   ┌──────────────────┐
   │ GitHub Actions   │
   │ Workflow Trigger │
   └──────────────────┘
          │
          ▼
   ┌──────────────────────────┐
   │ Azure Login              │
   │ (Service Principal)      │
   └──────────────────────────┘
          │
          ▼
   ┌──────────────────────────┐
   │ Get AKS Credentials      │
   │ az aks get-credentials   │
   └──────────────────────────┘
          │
          ▼
   ┌──────────────────────────┐
   │ Wait for AKS Nodes Ready │
   └──────────────────────────┘
          │
          ▼
   ┌──────────────────────────┐
   │ Deploy Kubernetes        │
   │ Manifests (AKS/)         │
   │ - deploy.yaml            │
   │ - service.yaml           │
   └──────────────────────────┘
          │
          ▼
   ┌──────────────────────────┐
   │ Wait for LoadBalancer IP │
   └──────────────────────────┘
          │
          ▼
   ┌──────────────────────────┐
   │ Application Accessible   │
   │ http://<LoadBalancer-IP> │
   └──────────────────────────┘


## Getting Started

### 1. Configure GitHub Actions

Workflow `.github/workflows/deploy.yml` automates deployment:

* Logs in to Azure using service principal.
* Retrieves AKS credentials via `az aks get-credentials`.
* Applies Kubernetes manifests (`deploy.yaml` and `service.yaml`).
* Waits for LoadBalancer IP and outputs it.

### 2. Access the Application

Check the LoadBalancer service:

```bash
kubectl get svc my-loadbalancer-service -n default
```

Access the app at:

```
http://<LoadBalancer-IP>/
```

### 3. Verify Pod Status

Ensure all application pods are running:

```bash
kubectl get pods -n default
```

## Updating the Application

1. Update the Kubernetes deployment image tag in `deploy.yaml`:

```yaml
image: oresky73/ghs-nginx-app46:<new-tag>
```

2. Push the updated manifest to the `main` branch. The workflow will:

    * Retrieve AKS credentials
    * Apply updated Kubernetes manifests
    * Wait for pods to be ready
    * Ensure LoadBalancer IP remains assigned

3. Verify the rollout:

```bash
kubectl rollout status deployment my-deployment -n default
kubectl get pods -n default
```

## Optional: Terraform Deployment

If AKS cluster does not exist:

```bash
cd INFRA
terraform init
terraform plan -out=tfplan
terraform apply -auto-approve tfplan
```

## Kubernetes Best Practices Implemented

* Resource **requests and limits** for pods
* **ServiceAccount tokens disabled**
* **LoadBalancer** exposes application externally
* Ready checks ensure pod health


## Troubleshooting

* **Pods pending:** Verify the image exists on DockerHub and cluster nodes have sufficient resources.
* **LoadBalancer IP not assigned:** Ensure Azure allows public IP provisioning.
* **Authentication errors:** Confirm GitHub secrets for Azure credentials.


## Future Enhancements

* Add **Ingress Controller** for domain routing and TLS termination
* Use **Helm charts** for templated deployments
* Add **readiness/liveness probes** for pod health
* Integrate **monitoring and logging** (Azure Monitor, Prometheus/Grafana)


## References

* [AKS Documentation](https://learn.microsoft.com/en-us/azure/aks/)
* [Docker Hub](https://hub.docker.com/)
* [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
* [GitHub Actions for Azure](https://github.com/Azure/actions)


## 🔐 DevSecOps Enhancements

* **Terraform state locking** with Azure Blob Storage
* **Secrets Store CSI Driver** for secure secrets injection
* Enable **RBAC and network policies** in AKS
* Scan container images with **Microsoft Defender for Containers**

DevSecOps
name: Provision, Secure & Deploy App to AKS

on:
  push:
    branches:
      - main
  workflow_dispatch:

env:
  IMAGE_NAME: docker.io/webaz
  IMAGE_TAG: latest
  NAMESPACE: default

# -------------------------
# 1) Pre-provision security
# -------------------------
jobs:
  security-scan:
    name: Pre-provision Security Scans
    runs-on: ubuntu-latest
    defaults:
      run:
        shell: bash
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      # CodeQL (SAST)
      - name: Initialize CodeQL
        uses: github/codeql-action/init@v3
        with:
          languages: 'javascript' # adjust to your repo languages
      - name: Run CodeQL analysis
        uses: github/codeql-action/analyze@v3

      # Semgrep (fast rules-based SAST)
      - name: Semgrep SAST
        uses: returntocorp/semgrep-action@v1
        with:
          config: "p/ci"

      # Secret scanning with TruffleHog
      - name: Secret scan (TruffleHog)
        uses: trufflesecurity/trufflehog@v3
        with:
          path: .
          fail: true

  # -----------------------------------------
  # 2) Provision: Terraform + IaC scanning
  # -----------------------------------------
  provision:
    name: Provision AKS with Terraform (with Checkov)
    runs-on: ubuntu-latest
    needs: security-scan
    defaults:
      run:
        shell: bash
    outputs:
      rg_name: ${{ steps.aks.outputs.rg_name }}
      aks_name: ${{ steps.aks.outputs.aks_name }}
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.9.5

      # Optional: create backend.tfvars only if you need it (uses AZURE_STORAGE_KEY secret)
      - name: Create backend.tfvars
        if: ${{ secrets.AZURE_STORAGE_KEY != '' }}
        run: |
          mkdir -p INFRA
          cat > INFRA/backend.tfvars <<EOF
          resource_group_name  = "aks-resource-group"
          storage_account_name = "k8scloudtfstateuks"
          container_name       = "tfstate"
          key                  = "terraform.tfstate"
          access_key           = "${{ secrets.AZURE_STORAGE_KEY }}"
          EOF

      # IaC Scanner (Checkov) — fail on policy violations
      - name: IaC Security Scan (Checkov)
        uses: bridgecrewio/checkov-action@v12
        with:
          directory: ./INFRA
          soft_fail: false

      - name: Terraform Init
        working-directory: ./INFRA
        env:
          ARM_CLIENT_ID: ${{ fromJson(secrets.AZURE_CREDENTIALS).clientId }}
          ARM_CLIENT_SECRET: ${{ fromJson(secrets.AZURE_CREDENTIALS).clientSecret }}
          ARM_SUBSCRIPTION_ID: ${{ fromJson(secrets.AZURE_CREDENTIALS).subscriptionId }}
          ARM_TENANT_ID: ${{ fromJson(secrets.AZURE_CREDENTIALS).tenantId }}
        run: |
          if [ -f "backend.tfvars" ]; then
            terraform init -backend-config="backend.tfvars"
          else
            terraform init
          fi

      - name: Terraform Plan
        working-directory: ./INFRA
        env:
          ARM_CLIENT_ID: ${{ fromJson(secrets.AZURE_CREDENTIALS).clientId }}
          ARM_CLIENT_SECRET: ${{ fromJson(secrets.AZURE_CREDENTIALS).clientSecret }}
          ARM_SUBSCRIPTION_ID: ${{ fromJson(secrets.AZURE_CREDENTIALS).subscriptionId }}
          ARM_TENANT_ID: ${{ fromJson(secrets.AZURE_CREDENTIALS).tenantId }}
        run: terraform plan -out=tfplan

      - name: Terraform Apply
        working-directory: ./INFRA
        env:
          ARM_CLIENT_ID: ${{ fromJson(secrets.AZURE_CREDENTIALS).clientId }}
          ARM_CLIENT_SECRET: ${{ fromJson(secrets.AZURE_CREDENTIALS).clientSecret }}
          ARM_SUBSCRIPTION_ID: ${{ fromJson(secrets.AZURE_CREDENTIALS).subscriptionId }}
          ARM_TENANT_ID: ${{ fromJson(secrets.AZURE_CREDENTIALS).tenantId }}
        run: terraform apply -auto-approve tfplan

      # Capture outputs (filter debug lines)
      - name: Get AKS Cluster Info
        id: aks
        working-directory: ./INFRA
        run: |
          AKS_NAME=$(terraform output -raw aks_name 2>/dev/null | grep -v "::" || echo "")
          RG_NAME=$(terraform output -raw resource_group_name 2>/dev/null | grep -v "::" || echo "")

          echo "AKS_NAME=${AKS_NAME}" >> $GITHUB_ENV
          echo "RG_NAME=${RG_NAME}" >> $GITHUB_ENV

          echo "aks_name=${AKS_NAME}" >> $GITHUB_OUTPUT
          echo "rg_name=${RG_NAME}" >> $GITHUB_OUTPUT

          echo "✅ AKS Cluster Name: ${AKS_NAME}"
          echo "✅ Resource Group: ${RG_NAME}"

  # ----------------------------------------------------
  # 3) Image build, scan and push (depends on provision)
  # ----------------------------------------------------
  image-build-scan:
    name: Build, Scan & Push Docker Image
    runs-on: ubuntu-latest
    needs: provision
    defaults:
      run:
        shell: bash
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Set up QEMU (for multi-platform builds, optional)
        uses: docker/setup-qemu-action@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Log in to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Build and push Docker image
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: ${{ env.IMAGE_NAME }}:${{ env.IMAGE_TAG }}
          file: ./Dockerfile

      - name: Scan image with Trivy
        uses: aquasecurity/trivy-action@v1
        with:
          image-ref: ${{ env.IMAGE_NAME }}:${{ env.IMAGE_TAG }}
          format: table
          exit-code: '1'         # fail on critical vulnerabilities
          vuln-type: 'os,library'

      - name: Upload image scan report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: trivy-report
          path: ./trivy-report.txt
        # Note: you can configure trivy to output to file if needed

  # ----------------------------------------------------
  # 4) Deploy to AKS (validate manifests first)
  # ----------------------------------------------------
  deploy:
    name: Deploy Application to AKS
    runs-on: ubuntu-latest
    needs:
      - image-build-scan
    defaults:
      run:
        shell: bash
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
          enable-AzPSSession: false
          environment: AzureCloud

      - name: Install stable Azure CLI
        run: |
          echo "🔧 Ensuring stable Azure CLI..."
          sudo apt-get update -y
          sudo apt-get install -y azure-cli
          az version

      # Get AKS credentials (use outputs from provision job)
      - name: Get AKS Credentials
        run: |
          echo "Retrieving AKS credentials..."
          RG_NAME="${{ needs.provision.outputs.rg_name }}"
          AKS_NAME="${{ needs.provision.outputs.aks_name }}"

          echo "Using Resource Group: $RG_NAME"
          echo "Using AKS Cluster: $AKS_NAME"

          az aks get-credentials \
            --resource-group "$RG_NAME" \
            --name "$AKS_NAME" \
            --overwrite-existing \
            --only-show-errors

      # Validate Kubernetes manifests (kube-linter)
      - name: Lint Kubernetes Manifests (kube-linter)
        uses: stackrox/kube-linter-action@v1
        with:
          directory: AKS/
          # optional: config: .kube-linter-config.yaml

      - name: Wait for AKS Nodes Ready
        run: |
          echo "Waiting for AKS nodes to be ready..."
          for i in {1..30}; do
            READY_NODES=$(kubectl get nodes --no-headers 2>/dev/null | grep -c ' Ready')
            TOTAL_NODES=$(kubectl get nodes --no-headers 2>/dev/null | wc -l)
            if [ "$TOTAL_NODES" -gt 0 ] && [ "$READY_NODES" -eq "$TOTAL_NODES" ]; then
              echo "✅ All $READY_NODES AKS nodes are ready!"
              break
            fi
            echo "Nodes not ready yet. Waiting 20s..."
            sleep 20
          done

      - name: Deploy Kubernetes Manifests
        run: |
          echo "🚀 Deploying Kubernetes manifests..."
          kubectl apply -f AKS/ || kubectl replace --force -f AKS/

      - name: Wait for LoadBalancer IP
        id: get-lb-ip
        run: |
          echo "Waiting for LoadBalancer IP..."
          for i in {1..30}; do
            IP=$(kubectl get svc lanik-lb-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
            if [ -n "$IP" ]; then
              echo "LoadBalancer IP is: $IP"
              echo "LB_IP=$IP" >> $GITHUB_ENV
              echo "lb_ip=$IP" >> $GITHUB_OUTPUT
              break
            fi
            echo "Still waiting for LoadBalancer IP... (Attempt $i)"
            sleep 10
          done

      - name: Show LoadBalancer IP
        run: |
          echo "✅ Application is accessible at: http://$LB_IP"

      # Upload cluster / deploy artifacts for later audit
      - name: Upload deployment artifacts
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: deployment-artifacts
          path: |
            AKS/
            INFRA/

## Final notes & recommendations

Fail-fast on high severity: The workflow above is configured to fail on critical findings (Checkov, Trivy, TruffleHog). Tune soft_fail or exit codes to match your team tolerance.

Least privilege: Ensure the AZURE_CREDENTIALS service principal has only the permissions required (Contributor on the RG or specific permissions for AKS + storage for state). Avoid Owner role.

Secrets / Key Vault: For production, store secrets in Azure Key Vault and fetch them during runtime rather than embedding storage account keys. You can use the azure/keyvault-secrets action.

Policy as code: Consider adding OPA/Gatekeeper in-cluster policies for runtime enforcement and admission controls.

Dashboarding: Upload all reports/artifacts to a centralized security dashboard or S3/Blob for audit and triage.

Dependabot: Add Dependabot config for dependencies + Terraform module updates (recommended).

## Next Steps:

Tailor the CodeQL languages / Semgrep rules to your repo.

Switch Docker push to Azure Container Registry (ACR) instead of Docker Hub.

Add an optional manual approval step between provision and deploy (for production).