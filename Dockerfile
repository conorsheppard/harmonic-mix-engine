# Build stage with full JDK
FROM eclipse-temurin:21-jdk-alpine AS builder
WORKDIR /
COPY . .
RUN ./gradlew clean bootJar -q -x test 2>/dev/null

# Runtime stage with JRE only
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=builder /app/build/libs/harmonic-mix-engine-1.0.0.jar harmonic-mix-engine.jar
ENTRYPOINT ["java", "-jar", "harmonic-mix-engine.jar"]