# Build stage using Java 21
FROM gradle:8-jdk21 AS build
WORKDIR /workspace
COPY . .
# Build the specific API app using the wrapper
RUN ./gradlew :apps:api:buildFatJar --no-daemon

# Runtime stage using Java 21
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /workspace/apps/api/build/libs/*-all.jar ./ktor-api.jar
EXPOSE 8080
# Cloud Run injects PORT; application.yaml uses 8080 as the local fallback.
CMD ["java", "-jar", "ktor-api.jar"]
