#!/bin/bash

set -e

echo "==> Running $(dirname "$(realpath "$0")")/build.sh"

date="$(date -Iseconds)"
docker --version
docker buildx version

function alpine()
{
    local alpine_version="$(cat .alpine-version)"
    local image_name="alpine"
    local image_registry="index.docker.io/cyayung804"

    export DATE="${date}"
    export ALPINE_VERSION="${alpine_version}"
    export IMAGE_NAME="${image_name}"
    export IMAGE_REGISTRY="${image_registry}"
    export IMAGE_TAG="${alpine_version}"

    cd "src/${image_name}" || exit 1

    if [[ "${IMAGE_TAG}" != "latest" ]] && crane ls "${image_registry}/${image_name}" | grep -q "${IMAGE_TAG}"; then
        echo "${image_registry}/${image_name}:${IMAGE_TAG} already exists..."
    else
        echo "Building ${image_registry}/${image_name}:${IMAGE_TAG}..."
        docker buildx bake push --no-cache
    fi
}

function golang()
{
    local alpine_version="$(cat .alpine-version)"
    local go_version="$(cat .go-version)"
    local image_name="golang"
    local image_registry="index.docker.io/cyayung804"

    export DATE="${date}"
    export ALPINE_VERSION="${alpine_version}"
    export GO_VERSION="${go_version}"
    export IMAGE_NAME="${image_name}"
    export IMAGE_REGISTRY="${image_registry}"
    export IMAGE_TAG="${go_version}"

    cd "src/${image_name}" || exit 1

    export image_tag="${IMAGE_TAG}-alpine${alpine_version}"

    if [[ "${IMAGE_TAG}" != "latest" ]] && crane ls "${image_registry}/${image_name}" | grep -q "${image_tag}"; then
        echo "${image_registry}/${image_name}:${image_tag} already exists..."
    else
        echo "Building ${image_registry}/${image_name}:${image_tag}..."
        docker buildx bake push --no-cache
    fi
}

function terraform()
{
    local alpine_version="$(cat .alpine-version)"
    local tf_version="$(cat .tf-version)"
    local image_registry="index.docker.io/cyayung804"
    local image_name="terraform"

    export DATE="${date}"
    export ALPINE_VERSION="${alpine_version}"
    export IMAGE_NAME="${image_name}"
    export IMAGE_REGISTRY="${image_registry}"
    export IMAGE_TAG="${tf_version}"
    export TF_VERSION="${tf_version}"

    cd "src/${image_name}" || exit 1

    export image_tag="${IMAGE_TAG}-alpine${alpine_version}"
    
    if [[ "${IMAGE_TAG}" != "latest" ]] && crane ls "${image_registry}/${image_name}" | grep -q "${image_tag}"; then
        echo "${image_registry}/${image_name}:${image_tag} already exists..."
    else
        echo "Building ${image_registry}/${image_name}:${image_tag}..."
        docker buildx bake push --no-cache
    fi
}

"$@"
