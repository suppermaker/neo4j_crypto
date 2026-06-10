#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"
ENV_EXAMPLE="${ROOT_DIR}/.env.example"

if [[ ! -f "${ENV_FILE}" ]]; then
  cp "${ENV_EXAMPLE}" "${ENV_FILE}"
  echo "Created .env from .env.example."
fi

set -a
# shellcheck disable=SC1090
source "${ENV_FILE}"
set +a

container="${NEO4J_CONTAINER_NAME:-crypto-neo4j}"
username="${NEO4J_USERNAME:-neo4j}"
password="${NEO4J_PASSWORD:-crypto_neo4j_password}"

run_cypher() {
  local file="$1"
  echo "Applying ${file#${ROOT_DIR}/} ..."
  docker exec -i "${container}" cypher-shell \
    -u "${username}" \
    -p "${password}" \
    < "${file}"
}

if ! docker exec "${container}" cypher-shell \
  -u "${username}" \
  -p "${password}" \
  "RETURN 1;" >/dev/null 2>&1; then
  echo "Neo4j is not ready. Start it with: scripts/neo4j.sh up" >&2
  exit 1
fi

run_cypher "${ROOT_DIR}/ontology/neo4j_schema.cypher"
run_cypher "${ROOT_DIR}/ontology/seed_dictionary.cypher"
run_cypher "${ROOT_DIR}/ontology/sample_evaluation_data.cypher"
run_cypher "${ROOT_DIR}/ontology/link_instances.cypher"

echo "Sample evaluation data loaded successfully."
