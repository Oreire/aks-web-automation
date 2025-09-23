# aks-deploy

Deploying a containerised application to an **Azure Kubernetes Service (AKS)** cluster using **Azure DevOps** and **Terraform** involves three key stages: **provisioning infrastructure**, **building and pushing the container**, and **deploying to AKS**. Here's a structured guide tailored to your DevSecOps practice and cloud-native delivery goals:

---

## 🧱 1. Provision AKS Infrastructure with Terraform

### ✅ Prerequisites
- Azure subscription and service principal with contributor access  
- Terraform installed and configured  
- Azure DevOps project with a connected repo

### 📦 Terraform Configuration
Create a `main.tf` file with modules to provision:
- Resource group  
- AKS cluster  
- Container registry (ACR)  
- Networking (optional)

Example snippet:
```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-cluster"
  location            = "UK South"
  resource_group_name = azurerm_resource_group.rg.name
  ...
}
```

### 🔁 Azure DevOps Pipeline (Terraform Stage)
Use a pipeline task to:
- Install Terraform  
- Initialise and apply the configuration  
- Store outputs (e.g. kubeconfig, ACR login server)

```yaml
- task: TerraformInstaller@1
- script: |
    terraform init
    terraform apply -auto-approve
```

---

## 🐳 2. Build and Push Container Image

### 🧪 Docker Build Pipeline
In Azure DevOps, define a pipeline to:
- Build the Docker image  
- Tag it with the ACR login server  
- Push it to ACR

```yaml
- task: Docker@2
  inputs:
    command: buildAndPush
    repository: myapp
    dockerfile: Dockerfile
    containerRegistry: $(ACR_SERVICE_CONNECTION)
    tags: latest
```

Ensure your service connection to ACR is securely configured.

---

## 🚀 3. Deploy to AKS

### 📄 Kubernetes Manifests
Create deployment and service YAML files:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 2
  template:
    spec:
      containers:
      - name: myapp
        image: <acr-login-server>/myapp:latest
```

### 🔧 Azure DevOps Deployment Stage
Use `kubectl` to apply manifests:
```yaml
- task: Kubernetes@1
  inputs:
    connectionType: Azure Resource Manager
    azureSubscription: '<your-subscription>'
    azureResourceGroup: '<your-rg>'
    kubernetesCluster: '<your-aks-cluster>'
    command: apply
    useConfigurationFile: true
    configuration: deployment.yaml
```

---

## 🔐 DevSecOps Enhancements
- Integrate **Terraform state locking** with Azure Storage  
- Use **Secrets Store CSI Driver** for secure secrets injection  
- Enable **RBAC and network policies** in AKS  
- Scan container images with **Microsoft Defender for Containers**

# Actions Workflow

name: Provision AKS and Deploy App

on:
  push:
    branches:
      - main
  workflow_dispatch:

env:
  IMAGE_NAME: oresky73/ghs-nginx-app42
  IMAGE_TAG: latest
  TERRAFORM_DIR: infra
  RESOURCE_GROUP: aks-resource-group
  AKS_CLUSTER_NAME: aks-cluster
  NAMESPACE: default

jobs:
  terraform-and-deploy:
    runs-on: ubuntu-latest
    defaults:
      run:
        shell: bash

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      # Terraform setup
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.7.5

      - name: Terraform Init
        working-directory: ${{ env.TERRAFORM_DIR }}
        run: terraform init

      - name: Terraform Plan
        working-directory: ${{ env.TERRAFORM_DIR }}
        run: terraform plan -out=tfplan

      - name: Terraform Apply
        working-directory: ${{ env.TERRAFORM_DIR }}
        run: terraform apply -auto-approve tfplan

      # Azure login
      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Get AKS Credentials
        run: |
          az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME --overwrite-existing

      # Wait for AKS nodes to be ready
      - name: Wait for AKS Nodes Ready
        run: |
          echo "Waiting for AKS nodes to be ready..."
          for i in {1..30}; do
            READY_NODES=$(kubectl get nodes --no-headers 2>/dev/null | grep -c ' Ready')
            TOTAL_NODES=$(kubectl get nodes --no-headers 2>/dev/null | wc -l)
            if [ "$TOTAL_NODES" -gt 0 ] && [ "$READY_NODES" -eq "$TOTAL_NODES" ]; then
              echo "All $READY_NODES AKS nodes are ready!"
              break
            fi
            echo "Nodes not ready yet. Waiting 20s..."
            sleep 20
          done

      # Docker build and push
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Docker Login
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Build Docker image
        run: docker build -t $IMAGE_NAME:$IMAGE_TAG .

      - name: Push Docker image
        run: docker push $IMAGE_NAME:$IMAGE_TAG

      # Deploy to Kubernetes
      - name: Deploy Kubernetes Manifests
        run: |
          kubectl apply -f k8s/deploy.yaml
          kubectl apply -f k8s/service.yaml

      - name: Wait for LoadBalancer IP
        run: |
          echo "Waiting for LoadBalancer IP..."
          for i in {1..30}; do
            IP=$(kubectl get svc my-loadbalancer-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
            if [ -n "$IP" ]; then
              echo "LoadBalancer IP is: $IP"
              break
            fi
            sleep 10
          done

