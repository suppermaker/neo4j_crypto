#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="${ROOT_DIR}/docker-compose.neo4j.yml"
ENV_FILE="${ROOT_DIR}/.env"
ENV_EXAMPLE="${ROOT_DIR}/.env.example"

compose() {
  docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" "$@"
}

ensure_env() {
  if [[ ! -f "${ENV_FILE}" ]]; then
    cp "${ENV_EXAMPLE}" "${ENV_FILE}"
    echo "Created .env from .env.example. Please change NEO4J_PASSWORD for non-local use."
  fi
}

load_env() {
  ensure_env
  set -a
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  set +a
}

wait_until_ready() {
  load_env
  local username="${NEO4J_USERNAME:-neo4j}"
  local password="${NEO4J_PASSWORD:-crypto_neo4j_password}"
  local container="${NEO4J_CONTAINER_NAME:-crypto-neo4j}"

  echo "Waiting for Neo4j to accept Cypher connections..."
  for _ in {1..60}; do
    if docker exec "${container}" cypher-shell -u "${username}" -p "${password}" "RETURN 1;" >/dev/null 2>&1; then
      echo "Neo4j is ready."
      return 0
    fi
    sleep 2
  done

  echo "Neo4j did not become ready in time. Check logs with: scripts/neo4j.sh logs" >&2
  return 1
}

case "${1:-help}" in
  up)
    ensure_env
    compose up -d
    wait_until_ready
    ;;
  down)
    ensure_env
    compose down
    ;;
  restart)
    ensure_env
    compose restart
    wait_until_ready
    ;;
  logs)
    ensure_env
    compose logs -f neo4j
    ;;
  status)
    ensure_env
    compose ps
    ;;
  shell)
    load_env
    docker exec -it "${NEO4J_CONTAINER_NAME:-crypto-neo4j}" cypher-shell -u "${NEO4J_USERNAME:-neo4j}" -p "${NEO4J_PASSWORD:-crypto_neo4j_password}"
    ;;
  clean)
    ensure_env
    compose down -v
    ;;
  help|*)
    cat <<'EOF'
Usage: scripts/neo4j.sh <command>

Commands:
  up        Start Neo4j
  down      Stop Neo4j
  restart   Restart Neo4j
  logs      Follow Neo4j logs
  status    Show container status
  shell     Open cypher-shell
  clean     Stop Neo4j and remove volumes

Neo4j Browser: http://localhost:7474
Bolt URI:       bolt://localhost:7687
EOF
    ;;
esac
