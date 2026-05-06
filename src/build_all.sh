#!/bin/bash

set -e

echo "==> Running $(dirname "$(realpath "$0")")/build_all.sh"

date="$(date -Iseconds)"
docker --version
docker buildx version

function alpine()
{
    local alpine_versions="$(sort -V .alpine-versions.txt)"
    local image_name="alpine"
    local image_registry="index.docker.io/cyayung804"

    export DATE="${date}"

    cd "src/${image_name}" || exit 1

    while read -r image_tag; do
        if crane ls "${image_registry}/${image_name}" | grep -q "${image_tag}"; then
            echo "${image_registry}/${image_name}:${image_tag} already exists..."
            continue
        fi
        export ALPINE_VERSION="${image_tag}"
        export IMAGE_NAME="${image_name}"
        export IMAGE_REGISTRY="${image_registry}"
        export IMAGE_TAG="${image_tag}"

        echo "Building ${image_registry}/${image_name}:${image_tag}..."
        mkdir -p "/tmp/build-logs/${image_name}"
        docker buildx bake push --progress=plain 2>&1 | tee -a "/tmp/build-logs/${image_name}/${image_tag}.log"
    done < <(echo "${alpine_versions}")
}

function golang()
{
    local alpine_versions="$(sort -V .alpine-versions.txt)"
    local go_versions="$(sort -V .go-versions.txt | head -n +57)" # index head -n +57 rebuild
    local image_name="golang"
    local image_registry="index.docker.io/cyayung804"

    export DATE="${date}"

    cd "src/${image_name}" || exit 1

    for alpine_version in ${alpine_versions}; do
        while read -r image_tag; do
            export image_tag="${image_tag}-alpine${alpine_version}"
            if [[ "${image_tag}" != "latest" ]] && crane ls "${image_registry}/${image_name}" | grep -q "${image_tag}"; then
                echo "${image_registry}/${image_name}:${image_tag} already exists..."
            else
                export ALPINE_VERSION="${alpine_version}"
                export GO_VERSION="${image_tag}"
                export IMAGE_NAME="${image_name}"
                export IMAGE_REGISTRY="${image_registry}"
                export IMAGE_TAG="${image_tag}"

                echo "Building ${image_registry}/${image_name}:${image_tag}..."
                docker buildx bake push --progress=plain
            fi
        done < <(echo "${go_versions}")
    done
}

function terraform()
{
    local alpine_versions="$(sort -V .alpine-versions.txt)"
    local tf_versions="$(sort -V .tf-versions.txt | head -n +137)" # index head -n +137 rebuild
    local image_name="terraform"
    local image_registry="index.docker.io/cyayung804"

    export DATE="${date}"

    cd "src/${image_name}" || exit 1

    for alpine_version in ${alpine_versions}; do
        while read -r image_tag; do
            export image_tag="${image_tag}-alpine${alpine_version}"
            if [[ "${image_tag}" != "latest" ]] && crane ls "${image_registry}/${image_name}" | grep -q "${image_tag}"; then
                echo "${image_registry}/${image_name}:${image_tag} already exists..."
            else
                export ALPINE_VERSION="${alpine_version}"
                export TF_VERSION="${image_tag}"
                export IMAGE_NAME="${image_name}"
                export IMAGE_REGISTRY="${image_registry}"
                export IMAGE_TAG="${image_tag}"

                echo "Building ${image_registry}/${image_name}:${image_tag}..."
                docker buildx bake push --progress=plain
            fi
        done < <(echo "${tf_versions}")
    done
}

"$@"
