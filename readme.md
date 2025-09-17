# Maven Hello World CI/CD Pipeline

A complete DevOps pipeline for a simple Java Maven application with GitHub Actions, Docker, and Helm Job deployment.

## 🚀 Features

- **Java Application**: Simple "Hello World from ${USER}!" Maven application
- **Automated Versioning**: Automatic patch version increment (1.0.0 → 1.0.1)
- **CI/CD Pipeline**: Complete GitHub Actions workflow
- **Docker Support**: Multi-stage Docker build with non-root user
- **Kubernetes Job**: Helm chart for running as a Kubernetes Job (not Deployment)
- **Security**: Non-root container execution and security contexts

## 📁 Project Structure

```
├── .github/workflows/
│   └── ci-cd.yml              # GitHub Actions CI/CD pipeline
├── myapp/                     # Maven application
│   ├── src/main/java/com/myapp/App.java
│   ├── src/test/java/com/myapp/AppTest.java
│   └── pom.xml
├── helm-chart/                # Helm chart for Kubernetes Job
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
├── Dockerfile                 # Multi-stage Docker build
└── README.md
```

## 🔧 Setup Instructions

### Prerequisites

1. **Docker Hub Account**: Required for pushing Docker images
2. **GitHub Repository**: Fork or create a new repository
3. **GitHub Secrets**: Add these secrets to your repository:
   - `DOCKER_USERNAME`: Your Docker Hub username
   - `DOCKER_PASSWORD`: Your Docker Hub password/access token
4. **Kubernetes Cluster**: For Helm Job deployment (optional for local testing)

### Local Development

1. **Build and run locally**:
   ```bash
   cd myapp
   mvn clean compile
   mvn package
   java -jar target/myapp-1.0.0.jar
   ```

2. **Build Docker image**:
   ```bash
   docker build -t maven-hello-world:latest .
   docker run --rm maven-hello-world:latest
   ```

3. **Test Helm chart**:
   ```bash
   helm lint helm-chart/
   helm template maven-hello-world helm-chart/
   ```

## 🔄 CI/CD Pipeline

The GitHub Actions pipeline automatically:

1. **Version Management**: Increments patch version (1.0.0 → 1.0.1)
2. **Build**: Compiles and tests the Java application
3. **Package**: Creates JAR artifact
4. **Docker**: Builds multi-stage Docker image with non-root user
5. **Registry**: Pushes to Docker Hub with version tags
6. **Deploy**: Deploys to Kubernetes as a Job using Helm
7. **Verify**: Tests the Job completion and logs

### Pipeline Triggers

- Push to `master` branch
- Pull requests to `master` branch

## 🐳 Docker Details

### Multi-stage Build
- **Builder Stage**: Maven build with dependency caching (`RUN mvn dependency:go-offline -B`)
- **Runtime Stage**: Lightweight JRE with security hardening

### Security Features
- Non-root user execution (Alpine user)
- Security contexts and constraints
- Minimal attack surface with JRE-only runtime

### Image Tags
- `latest`: Always points to the most recent build
- `x.y.z`: Specific version tags (e.g., `1.0.1`, `1.0.2`)

## ⎈ Kubernetes Job Deployment

### Helm Chart Features
- **Security**: Pod security contexts and non-root execution
- **Job**: Runs the app as a Kubernetes Job (not a Deployment)
- **Configuration**: Environment variables and resource limits

### Job Deployment Commands
```bash
# Install as a Job
helm install maven-hello-world helm-chart/

# Upgrade
helm upgrade maven-hello-world helm-chart/

# Uninstall
helm uninstall maven-hello-world
```

### Access Job Output
```bash
# Get job logs
kubectl logs job/maven-hello-world-job -n <namespace>

# Check job status
kubectl get jobs -n <namespace>
kubectl describe job maven-hello-world-job -n <namespace>

# See pods created by the job
kubectl get pods --selector=job-name=maven-hello-world-job -n <namespace>
```

## 🛠️ Configuration

### Values.yaml Customization
```yaml
image:
  repository: your-dockerhub-username/maven-hello-world
  tag: "1.0.1"

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

### Environment Variables
```yaml
app:
  env:
    - name: JAVA_OPTS
      value: "-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"
```

## 🔍 Monitoring and Troubleshooting

### Check Pipeline Status
- Go to GitHub Actions tab in your repository
- Monitor build logs and job status

### Debug Kubernetes Job
```bash
# Check jobs
kubectl get jobs -n maven-hello-world

# Check logs
kubectl logs job/maven-hello-world-job -n maven-hello-world

# Describe job
kubectl describe job maven-hello-world-job -n maven-hello-world
```

### Common Issues
1. **Docker Hub Authentication**: Ensure secrets are correctly set
2. **Version Conflicts**: Check if version already exists in registry
3. **Kubernetes Resources**: Verify cluster has sufficient resources

