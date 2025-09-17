

# Local testing script for Maven Hello World application
set -e

echo "🔧 Testing Maven Hello World Application..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test Maven build
echo -e "${YELLOW}📦 Testing Maven build...${NC}"
cd myapp
mvn clean compile
mvn test
mvn package -DskipTests

echo -e "${GREEN}✅ Maven build successful!${NC}"

# Test JAR execution
echo -e "${YELLOW}☕ Testing JAR execution...${NC}"
java -jar target/myapp-1.0.0.jar

# Return to root directory
cd ..

# Test Docker build
echo -e "${YELLOW}🐳 Testing Docker build...${NC}"
docker build -t maven-hello-world:test .

echo -e "${GREEN}✅ Docker build successful!${NC}"

# Test Docker run
echo -e "${YELLOW}🚀 Testing Docker run...${NC}"
docker run --rm maven-hello-world:test

# Test Helm chart validation
echo -e "${YELLOW}⎈ Testing Helm chart...${NC}"
if command -v helm &> /dev/null; then
    helm lint helm-chart/
    echo -e "${GREEN}✅ Helm chart validation successful!${NC}"
    
    # Generate Kubernetes manifests
    echo -e "${YELLOW}📄 Generating Kubernetes manifests...${NC}"
    helm template maven-hello-world helm-chart/ > k8s-manifests.yaml
    echo -e "${GREEN}✅ Kubernetes manifests generated in k8s-manifests.yaml${NC}"
else
    echo -e "${YELLOW}⚠️  Helm not installed, skipping chart validation${NC}"
fi

# Clean up test artifacts
echo -e "${YELLOW}🧹 Cleaning up...${NC}"
docker rmi maven-hello-world:test || true

echo -e "${GREEN}🎉 All tests passed! Ready for CI/CD pipeline.${NC}"

echo -e "\n${YELLOW}Next steps:${NC}"
echo "1. Update Docker Hub username in helm-chart/values.yaml"
echo "2. Add DOCKER_USERNAME and DOCKER_PASSWORD secrets to GitHub"
echo "3. Push to GitHub to trigger the CI/CD pipeline"
echo "4. Monitor the pipeline in GitHub Actions"
