#!/usr/bin/env bash
set -euo pipefail

REGISTRY="kitofoso"
TAG="${IMAGE_TAG:-$(git rev-parse --short HEAD)}"

# Mỗi phần tử có dạng tên-service:cổng
SERVICES=(
  "config-server:8888"
  "discovery-server:8761"
  "customers-service:8081"
  "visits-service:8082"
  "vets-service:8083"
  "api-gateway:8080"
)

for entry in "${SERVICES[@]}"; do
  name="${entry%%:*}"     # phần trước dấu :
  port="${entry##*:}"     # phần sau dấu :
  module="spring-petclinic-${name}"
  jar="$(ls "${module}"/target/*.jar | head -n 1)"
  artifact="$(basename "${jar}" .jar)"
  image="${REGISTRY}/${module}:${TAG}"

  echo "==> Building ${image}"
  docker build -f docker/Dockerfile \
    --build-arg ARTIFACT_NAME="${artifact}" \
    --build-arg EXPOSED_PORT="${port}" \
    -t "${image}" \
    "${module}/target"

  if [[ "${1:-}" == "--push" ]]; then
    docker push "${image}"
  fi
done

echo "Done. Tag: ${TAG}"