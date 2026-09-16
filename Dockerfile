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
# The container will rely on the PORT environment variable injected by Cloud Run
CMD ["java", "-jar", "ktor-api.jar"]
