# Build stage with full JDK
FROM eclipse-temurin:21-jdk-alpine AS builder
WORKDIR /
COPY . .
RUN ./gradlew clean bootJar -q -x test 2>/dev/null

# Runtime stage with JRE only
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=builder /backend/build/libs/harmonic-mix-engine.jar harmonic-mix-engine.jar
ENTRYPOINT ["java", "-jar", "harmonic-mix-engine.jar"]
