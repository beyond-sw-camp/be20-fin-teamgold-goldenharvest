#!/bin/bash

# 1. 에러 발생 시 즉시 중단
set -e

echo "🚀 [1/3] 빌드 시작: Common 모듈..."
cd config/common
chmod +x gradlew
./gradlew clean jar
cd ../..

# 2. 빌드된 JAR를 루트의 libs 폴더로 모으기 (관리 편의성)
echo "📦 [2/3] JAR 파일 추출 및 정리..."
mkdir -p libs
cp config/common/build/libs/*.jar libs/common-all.jar

# 3. Docker Compose 실행
echo "🐳 [3/3] Docker 컨테이너 빌드 및 실행..."
# 기존에 꼬여있던 컨테이너 정리 후 빌드
docker-compose down
docker-compose up --build -d

echo "✅ 모든 서비스가 백그라운드에서 실행 중입니다!"
