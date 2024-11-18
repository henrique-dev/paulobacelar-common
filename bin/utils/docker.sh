#!/usr/bin/env sh

docker_command=""

if command -v docker-compose &> /dev/null; then
  docker_command="docker-compose"
elif command -v docker compose &> /dev/null; then
  docker_command="docker compose"
else
  echo "Neither docker-compose nor docker compose is installed"
  exit 1
fi

function wait_for_container() {
  waiting_done="false"
  echo -e "${BLUE}Waiting for container: $1${NC}"
  while [[ "${waiting_done}" != "true" ]]; do
    container_state="$(docker inspect "$1" --format '{{ .State.Status }}')"
    if [[ "${container_state}" == "running" ]]; then
      health_status="$(docker inspect "$1" --format '{{ .State.Health.Status }}')"
      if [[ ${health_status} == "healthy" ]]; then
        waiting_done="true"
      fi
      if [[ ${health_status} == "unhealthy" ]]; then
        echo -e "${RED}The container "$1" failed to start successfully${NC}"
        exit 1
      fi
    else
      health_status="$(docker inspect "$1" --format '{{ .State.Health.Status }}')"
      if [[ ${health_status} == "unhealthy" ]]; then
        echo -e "${RED}The container "$1" failed to start successfully${NC}"
        exit 1
      fi
      waiting_done="true"
    fi
    sleep 1;
  done;
}