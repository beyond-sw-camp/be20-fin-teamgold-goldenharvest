# === 1단계: Build ===
FROM amazoncorretto:21-alpine AS builder
WORKDIR /build

# 1. Gradle 설정 파일만 먼저 복사
COPY gradlew .
COPY gradle gradle
COPY build.gradle* .
COPY settings.gradle* .

# 2. 의존성 다운로드 (실행 권한 부여 포함)
# 여기서 한 번 권한을 주어 의존성을 내려받습니다.
RUN --mount=type=cache,target=/root/.gradle \
    chmod +x ./gradlew && ./gradlew dependencies --no-daemon

# 3. 소스 전체 복사
COPY . .

# 4. 권한 재부여 및 빌드 (중요: COPY . . 이후에 실행 권한이 사라질 수 있음)
# exit code 126 방지를 위해 chmod +x를 빌드 직전에 실행합니다.
RUN --mount=type=cache,target=/root/.gradle \
    chmod +x ./gradlew && ./gradlew bootJar -x test --no-daemon

# === 2단계: Run ===
FROM amazoncorretto:21-alpine
WORKDIR /app

# 빌드된 JAR 복사
COPY --from=builder /build/build/libs/*.jar app.jar

EXPOSE 8080

# 컨테이너 환경에 최적화된 JVM 옵션
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]