FROM eclipse-temurin:21-jre

LABEL org.opencontainers.image.source="https://github.com/Rohan-HC/springboot-blue-green-k8s"
LABEL org.opencontainers.image.description="Spring Boot Blue-Green deployment on Kubernetes"

WORKDIR /app

COPY target/bluegreen-0.0.1-SNAPSHOT.jar app.jar

ARG APP_VERSION=1.0
ARG APP_ENVIRONMENT=blue

ENV APP_VERSION=${APP_VERSION}
ENV APP_ENVIRONMENT=${APP_ENVIRONMENT}

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]