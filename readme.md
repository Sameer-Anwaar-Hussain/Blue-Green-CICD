# Blue-Green Deployment with CI/CD Pipeline on Kubernetes

## Project Overview
This project implements a **Blue-Green Deployment** strategy with a CI/CD pipeline for a Java-based Spring Boot application deployed on Kubernetes (AWS EKS). It integrates tools like Jenkins, SonarQube, Trivy, Nexus, and Docker to automate and secure the deployment process.

Key features include:
- **Zero Downtime Deployments** using Blue/Green strategy.
- **Artifact Management** using Nexus Maven repositories.
- **Continuous Integration and Deployment** powered by Jenkins.
- **Infrastructure as Code** with Terraform for EKS provisioning.

---

## Tools and Technologies
- **AWS EKS**: Managed Kubernetes service for deploying containerized applications.
- **Terraform**: Infrastructure provisioning and management.
- **Jenkins**: CI/CD pipeline automation.
- **SonarQube**: Code quality and security analysis tool.
- **Nexus**: Artifact repository for Maven builds.
- **Trivy**: Vulnerability scanning for Docker images.
- **Docker**: Containerization for the Spring Boot application.

---

## Virtual Machine Setup

### Kubernetes Management Server
- **Purpose**: To manage EKS cluster resources.
- **Recommended Specs**:
  - CPU: 2 vCPUs
  - RAM: 4GB
  - Disk: 20GB

### Jenkins VM
- **Purpose**: Host Jenkins for automating CI/CD workflows.
- **Recommended Specifications**:
  - CPU: 2 vCPUs
  - RAM: 8GB
  - Disk: 20GB
- **Tools Installed**:
  - Docker
  - Jenkins 

### SonarQube VM
- **Purpose**: Host SonarQube for code quality analysis.
- **Recommended Specifications**:
  - CPU: 2 vCPUs
  - RAM: 4GB
  - Disk: 20GB
- **Tools Installed**:
  - Docker
  - SonarQube (hosted in a Docker container).

### Nexus VM
- **Purpose**: Host Nexus for managing Maven artifacts.
- **Recommended Specifications**:
  - CPU: 2 vCPUs
  - RAM: 4GB
  - Disk: 20GB
- **Tools Installed**:
  - Docker
  - Nexus (hosted in a Docker container).
---

## Setting Up Nexus
- **Install and Run Nexus**
```bash
sudo apt-get update
sudo apt-get install -y docker.io
docker run -d --name nexus -p 8081:8081 sonatype/nexus3:latest
```
### Access Nexus
```bash
Navigate to http://<NEXUS_VM_IP>:8081.
Retrieve the admin password:
docker exec -it <container_id> /bin/bash
cat /nexus-data/admin.password
```

## Setting Up SonarQube
- **Install and Run SonarQube**
```bash
sudo apt-get update
sudo apt-get install -y docker.io
docker run -d --name sonarqube -p 9000:9000 sonarqube:community
```
### Create Maven Repositories
```bash
Go to Repositories > Create Repository.
Create:
maven-releases: For release artifacts.
maven-snapshots: For snapshot artifacts.
```

### Setting Up Jenkins
**Install Plugins**
- **Install the following Jenkins plugins:**
- **1.SonarQube Scanner**
- **2.Config file provider**
- **3.Maven Integration**
- **4.Pipeline maven integration.**
- **5.Kubernetes**
- **6.Kubernetes Client API**
- **7.Kubernetes Credentials**
- **8.Kubernetes CLI**
- **9.Docker**
- **10.Docker Pipeline**
- **11.Pipeline Stage View**
- **12.Eclipse Temurin Installer**

- **Add Maven and JDK tools under Manage Jenkins > Global Tool Configuration.**

### Update the pom.xml file to include Nexus repository URLs:
```bash
<distributionManagement>
    <repository>
        <id>maven-releases</id>
        <url>http://<NEXUS_VM_IP>:8081/repository/maven-releases/</url>
    </repository>
    <snapshotRepository>
        <id>maven-snapshots</id>
        <url>http://<NEXUS_VM_IP>:8081/repository/maven-snapshots/</url>
    </snapshotRepository>
</distributionManagement>
```
### Setting Up Kubernetes
#### Provision EKS Cluster
#### Use Terraform to provision the EKS cluster:
```bash
terraform init
terraform plan
terraform apply
```

### Deploy the RBAC Configuration for Jenkins to interact with Kubernetes. See EKS RBAC Setup.

## CI/CD Pipeline Flow
### Pipeline Stages:
#### Git Checkout:
**Clone the source code from GitHub.**
#### Maven Build:
Run ```bash mvn clean package ``` to generate the JAR file and upload artifacts to Nexus.
#### SonarQube Analysis:
**Perform static code analysis using SonarQube.**
#### Trivy Scans:
**Scan the project files and Docker images for vulnerabilities.**
#### Docker Build and Push:
**Build the Docker image using the Maven-generated JAR file and push it to a Docker registry.**
#### Kubernetes Deployment:
**Deploy the application to Kubernetes using the Blue/Green strategy.**
#### Traffic Switching:
**Switch traffic between Blue and Green environments.**
### Blue-Green Deployment
#### Blue Environment
 The stable, production-ready environment.
#### Green Environment
The new environment for testing updates or new releases.
#### Switching Traffic
To switch traffic to the Green environment:
```bash
kubectl patch service banking-app-service -p '{"spec": {"selector": {"app": "banking-app", "version": "green"}}}' -n banking-namespace
```
### Verifying Deployment:

Check Pods
```bash
kubectl get pods -n banking-namespace
```
### Check Services: 
```bash
kubectl get svc -n banking-namespace
```
### Access Application
Use the external IP of the LoadBalancer service to access the app.
## References
RBAC Configuration: EKS RBAC Setup
Kubernetes Documentation: Kubernetes Official Docs