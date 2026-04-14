# Project Architecture

This document describes the architectural components and deployment flow of the project.

## System Architecture Diagram

```mermaid
graph TD
    subgraph "CI/CD (GitHub Actions)"
        GA_Infra[infra_deploy.yml]
        GA_Docker[docker_deploy.yml]
    end

    subgraph "Infrastructure as Code (Terraform)"
        T_Net[Network Module] -- "VPC/Subnet ID" --> T_Comp[Compute Module]
        T_Comp -- "Instance IP" --> T_CF[Cloudflare Module]
    end

    subgraph "Configuration Management (Ansible)"
        A_K3s[k3s Role]
        A_CFD[cloudflared Role]
        A_K8s[k8s_deploy Role]
    end

    subgraph "GCP Infrastructure"
        VM[GCE Instance]
        subgraph "K3s Cluster"
            APP[web_docker Pods]
            SVC[K8s Service]
            HPA[Horizontal Pod Autoscaler]
        end
        CFD_Proc[cloudflared Process]
    end

    %% Flow Relationships
    GA_Infra --> T_Net
    GA_Infra --> A_K3s
    GA_Docker --> APP
    
    T_Comp --> VM
    A_K3s --> VM
    A_CFD --> CFD_Proc
    A_K8s --> APP
    
    CFD_Proc <--> SVC
    SVC --> APP
```

## Component Overview

### 1. CI/CD (GitHub Actions)
- **`infra_deploy.yml`**: Provisions infrastructure using Terraform and configures the environment using Ansible.
- **`docker_deploy.yml`**: Builds and pushes the application Docker image, then updates the Kubernetes deployment.

### 2. Infrastructure as Code (Terraform)
- **Network Module**: Configures the VPC and subnets within Google Cloud Platform (GCP).
- **Compute Module**: Provisions the Google Compute Engine (GCE) instance where the cluster resides.
- **Cloudflare Module**: Manages DNS records and security settings, pointing to the provisioned infrastructure.

### 3. Configuration Management (Ansible)
- **k3s Role**: Installs and configures a lightweight Kubernetes (K3s) distribution.
- **cloudflared Role**: Sets up a Cloudflare Tunnel for secure, ingress-less access to the cluster.
- **k8s_deploy Role**: Deploys Kubernetes manifests including Deployments, Services, and HPAs.

### 4. Application (web_docker)
- A Dockerized web application (Nginx-based) serving `index.html`.
- Managed as a Kubernetes Deployment within the K3s cluster, with automatic scaling via HPA.
