#!/usr/bin/env bash
set -euo pipefail
REGISTRY="kitofoso"
TAG="$(git rev-parse --short HEAD)"

#mỗi phần tử có dạng tên ->tên-service, ví dụ: api-gateway, config-server, discovery-server, hay customer-service
SERVICES=(
    "config-server:8888"
    "discovery-server:8761"
    "api-gateway:8080"
    "customer-service:8081"
    "vet-service:8082"
    "visit-service:8083"
)

for entry in "${SERVICES[@]}"; do
    name="${entry%%:*}"
    port="${entry##*:}"
    module="spring-petclinic-$name"
    jar="$(ls target/$module-*.jar | head -n 1)"
    artifact="$(basename "$jar" .jar)"
    image="$REGISTRY/$artifact:$TAG"

    echo  "=> Building Docker image for $module"
    docker build -f docker/Dockerfile\ \
        --build-arg ARTIFACT_NAME="$artifact" \
        --build-arg EXPOSED_PORT="$port" \
        -t "$image" \
        "${module}/target"
    if [["${1:-}" == "--push" ]]; then
        echo "=> Pushing Docker image for $module"
        docker push "$image"
    fi
done

echo "Done. Tag: $TAG"
