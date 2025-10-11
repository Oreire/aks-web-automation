
#  Automated Secure, Scalable & Observable Web Application Deployment on Azure AKS

### *Using Terraform • GitHub Actions • Argo CD • Prometheus • Grafana*


## Overview

This project delivers a **cloud-native DevSecOps deployment pipeline** for a containerised web application hosted on **Azure Kubernetes Service (AKS)**. The workflow automates **infrastructure provisioning**, **Kubernetes deployment**, **GitOps delivery**, **security scanning**, and **observability** using **Terraform**, **GitHub Actions**, **Argo CD**, and **Prometheus/Grafana**.


## 🧩 Key Features

| Capability                       | Description                                                            |
| -------------------------------- | ---------------------------------------------------------------------- |
| **Infrastructure-as-Code (IaC)** | AKS cluster and networking managed with Terraform                      |
| **Continuous Deployment (CD)**   | Automated deployment via GitHub Actions (`.github/workflows/aks.yaml`) |
| **GitOps**                       | Continuous delivery and self-healing deployments using Argo CD         |
| **Security Automation**          | Multi-layered scanning (CodeQL, Trivy, Checkov, Semgrep, TruffleHog)   |
| **Autoscaling**                  | Horizontal Pod Autoscaler (HPA) automatically scales pods              |
| **Observability**                | Prometheus and Grafana provide monitoring and visualisation            |
| **High Availability**            | Azure-managed Kubernetes with rolling updates and resilience           |



##  Tech Stack

* **Terraform** — Infrastructure provisioning
* **Azure Kubernetes Service (AKS)** — Managed Kubernetes platform
* **GitHub Actions** — CI/CD workflow (`aks.yaml`)
* **Argo CD** — GitOps continuous delivery controller
* **Prometheus & Grafana** — Monitoring and visualisation
* **Helm** — Chart-based installation for Argo CD and monitoring stack


## 🗂️ Repository Structure


├── INFRA/
│   ├── main.tf            # Terraform AKS and networking configuration
│   ├── provider.tf        # Azure provider and backend configuration
│   ├── variables.tf       # Input variables
│   └── outputs.tf         # Output values (AKS name, RG name, etc.)
│
├── AKS/
│   ├── deploy.yaml        # Application Deployment manifest
│   ├── service.yaml       # LoadBalancer Service
│   └── hpa.yaml           # Horizontal Pod Autoscaler
│
├── ArgoCD/
│   ├── argocd-app.yaml    # Argo CD Application definition
│   └── project.yaml       # Argo CD Project definition
│
├── .github/workflows/
│   └── aks.yaml           # GitHub Actions workflow
│
└── README.md

## ⚙️ CI/CD Workflow (`aks.yaml`)

The **GitHub Actions pipeline** automates security scanning, infrastructure provisioning, deployment, and verification.

### 🧭 Workflow Stages

1. **Security Scans**

   * **CodeQL** → code vulnerability analysis
   * **Trivy** → container vulnerability scan
   * **Checkov** → Terraform and IaC scanning
   * **Semgrep** → static application security testing (SAST)
   * **TruffleHog** → secret leakage detection

2. **Terraform Provisioning**

   * Authenticates with Azure via Service Principal
   * Initialises remote backend
   * Provisions AKS cluster and networking
   * Outputs key values (`aks_name`, `resource_group_name`)

3. **Kubernetes Deployment**

   * Fetches cluster credentials using `az aks get-credentials`
   * Applies manifests:
   * Verifies connectivity to the LoadBalancer

4. **GitOps with Argo CD**

   * Deploys and syncs the application directly from the GitHub repository
   * Enables drift detection and self-healing

5. **Observability Setup**

   * Installs Prometheus and Grafana via Helm
   * Exposes Grafana dashboard for real-time monitoring



## 🔐 Security Controls

* Azure Service Principal with least-privilege access
* Terraform remote state stored securely in Azure Blob Storage
* Network isolation via AKS network policies
* Container image scanning via Trivy
* Secret validation via TruffleHog
* Infrastructure compliance checks with Checkov


## ⚡ Horizontal Pod Autoscaler (HPA) Example

This configuration dynamically scales your pods between **2–6 replicas** based on CPU usage.


## 🎯 Argo CD Integration

### 1️⃣ Install Argo CD


### 2️⃣ Expose Argo CD Server

```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
kubectl get svc argocd-server -n argocd
```

Access the Argo CD UI at:
`http://<ARGOCD_EXTERNAL_IP>`

### 3️⃣ Login to Argo CD

```bash
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 --decode
```

**Username:** `admin`


## 📈 Observability with Prometheus & Grafana

### Install Prometheus & Grafana

```bash
kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install kube-prom prometheus-community/kube-prometheus-stack -n monitoring
```

### Access Grafana Dashboard

```bash
kubectl get svc -n monitoring
kubectl port-forward svc/kube-prom-grafana 3000:80 -n monitoring
```

Access Grafana at: [http://localhost:3000](http://localhost:3000)
**Default credentials:** `admin / prom-operator`

---

## 🌐 Accessing the Application

Once deployed:

```bash
kubectl get svc lanik-lb-service -n default
```

Example output:

```
NAME               TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)        AGE
lanik-lb-service   LoadBalancer   10.0.213.65   4.250.192.95    80:31690/TCP   5m

```

Access via your browser:
👉 `http://4.250.192.95`

---

## 🧠 Troubleshooting

| Issue                               | Cause                       | Resolution                                       |
| ----------------------------------- | --------------------------- | ------------------------------------------------ |
| LoadBalancer IP pending             | Azure IP allocation delay   | Wait or verify Public IP quotas                  |
| Pods in `ErrImagePull`              | Image not found/private     | Verify image name and registry permissions       |
| Argo CD not syncing                 | YAML error or access denied | Check `kubectl describe app lanik-app -n argocd` |
| No metrics in Grafana               | Prometheus misconfigured    | Restart Prometheus pods                          |
| Terraform “resource already exists” | Existing Azure resources    | Import to state or rename resource               |


## 🔮 Future Enhancements

* Add NGINX Ingress Controller with TLS
* Integrate OPA Gatekeeper for policy enforcement
* Implement Argo Rollouts for canary deployments
* Centralise logs via Azure Log Analytics
* Automate Helm releases for Grafana dashboards



## 👨‍💻 Author

**Larry Ajayi**
*DevSecOps & Cloud Engineer*
💡 *Azure | Kubernetes | Terraform | Argo CD | CI/CD Automation*

