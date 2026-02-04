# syntax=docker/dockerfile:1
FROM amazoncorretto:21-alpine AS builder
WORKDIR /build

# 1. 빌드 타겟 서비스 이름 받기
ARG SERVICE_NAME

# 2. 서비스 전용 Gradle 래퍼 및 설정 파일 복사
# 루트에 gradlew가 없으므로 서비스 폴더 내의 것을 활용합니다.
COPY apps/${SERVICE_NAME}/gradlew .
COPY apps/${SERVICE_NAME}/gradle gradle
COPY apps/${SERVICE_NAME}/build.gradle apps/${SERVICE_NAME}/settings.gradle ./apps/${SERVICE_NAME}/

# 3. 공통 JAR 및 소스 복사
COPY libs/common-all.jar libs/common-all.jar
COPY apps/${SERVICE_NAME}/src ./apps/${SERVICE_NAME}/src

# 4. 빌드 실행
# -p 옵션을 사용하여 해당 서비스 프로젝트 경로에서 직접 빌드합니다.
RUN chmod +x gradlew
RUN ./gradlew -p apps/${SERVICE_NAME} bootJar --no-daemon -x test

# 실행 스테이지
FROM amazoncorretto:21-alpine
WORKDIR /app

ARG SERVICE_NAME
# 빌드된 JAR만 복사 (빌드 방식에 따라 경로가 다를 수 있어 와일드카드 사용)
COPY --from=builder /build/apps/${SERVICE_NAME}/build/libs/*.jar app.jar

ENTRYPOINT ["java", "-jar", "app.jar"]