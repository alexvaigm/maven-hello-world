# Multi-stage Docker build for Maven Hello World application

# Stage 1: Build stage
FROM maven:3.8.6-openjdk-17-slim AS builder

# Set working directory
WORKDIR /app

# Copy pom.xml first for better layer caching
COPY myapp/pom.xml .

# Download dependencies (this layer will be cached if pom.xml doesn't change)
RUN mvn dependency:go-offline -B

# Copy source code
COPY myapp/src ./src

# Build the application
RUN mvn clean package -DskipTests -B

# Stage 2: Runtime stage
FROM openjdk:17-jre-slim

# Create a non-root user
RUN groupadd -r appuser && useradd --no-log-init -r -g appuser appuser

# Set working directory
WORKDIR /app

# Copy the built JAR from the builder stage
COPY --from=builder /app/target/*.jar app.jar

# Change ownership of the app directory to the non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port (if your app uses one, default to 8080)
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD java -version || exit 1

# Set JVM options for better containerized performance
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -Djava.security.egd=file:/dev/./urandom"

# Run the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
