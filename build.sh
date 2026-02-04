#!/bin/bash

# 색상 정의 (출력 가독성용)
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== GH Project Docker Build Helper ===${NC}"

# BuildKit 활성화 환경변수 설정
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

function usage() {
    echo "사용법: ./build.sh [option] [service_name]"
    echo "옵션:"
    echo "  up      : 전체 서비스를 병렬 빌드하고 실행합니다."
    echo "  build   : 전체 서비스를 병렬 빌드만 수행합니다."
    echo "  clean   : 모든 캐시를 삭제하고 '완전 처음부터' 다시 빌드합니다. (속도 테스트용)"
    echo "  service : 특정 서비스만 빌드합니다. (예: ./build.sh service auth-service)"
    echo "  down    : 모든 컨테이너를 중지하고 삭제합니다."
}

case "$1" in
    up)
        echo -e "${GREEN}전체 서비스를 빌드 및 실행합니다...${NC}"
        docker-compose up --build -d
        ;;
    build)
        echo -e "${GREEN}전체 서비스를 병렬 빌드합니다...${NC}"
        time docker-compose build --parallel
        ;;
    clean)
        echo -e "${RED}주의: 모든 빌드 캐시를 삭제하고 새로 빌드합니다...${NC}"
        docker-compose down --rmi all
        docker builder prune -f
        docker builder prune --filter type=exec.cachemount -f
        echo -e "${GREEN}클린 빌드 시작...${NC}"
        time docker-compose build --parallel
        ;;
    service)
        if [ -z "$2" ]; then
            echo -e "${RED}에러: 서비스 이름을 입력해주세요.${NC}"
            usage
        else
            echo -e "${GREEN}$2 서비스만 빌드합니다...${NC}"
            time docker-compose build "$2"
        fi
        ;;
    down)
        echo -e "${BLUE}컨테이너를 종료합니다...${NC}"
        docker-compose down
        ;;
    *)
        usage
        ;;
esac