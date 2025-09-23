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

* **Terraform state locking** with Azure Storage
* **Secrets Store CSI Driver** for secure secrets injection
* Enable **RBAC and network policies** in AKS
* Scan container images with **Microsoft Defender for Containers**

