#!/bin/bash

set -e

echo "==> Running $(dirname "$(realpath "$0")")/build_all.sh"

date="$(date -Iseconds)"
docker --version
docker buildx version

function alpine()
{
    local alpine_versions="$(cat .alpine-versions.txt | sort -V)"
    local image_name="alpine"
    local image_registry="index.docker.io/cyayung804"

    export DATE="${date}"

    cd "src/${image_name}" || exit 1

    while read -r IMAGE_TAG; do
        if crane ls "${image_registry}/${image_name}" | grep -q "${IMAGE_TAG}"; then
            echo "${image_registry}/${image_name}:${IMAGE_TAG} already exists..."
            continue
        fi
        export ALPINE_VERSION="${IMAGE_TAG}"
        export IMAGE_NAME="${image_name}"
        export IMAGE_REGISTRY="${image_registry}"
        export IMAGE_TAG="${IMAGE_TAG}"

        echo "Building ${image_registry}/${image_name}:${IMAGE_TAG}..."
        docker buildx bake push --no-cache
    done < <(echo "${alpine_versions}")
}

function golang()
{
    local alpine_versions="$(sort -V .alpine-versions.txt)"
    local go_versions="$(cat .go-versions.txt | head -n +48 | sort -V)" # index head -n +48 rebuild
    local image_name="golang"
    local image_registry="index.docker.io/cyayung804"

    export DATE="${date}"

    cd "src/${image_name}" || exit 1

    for alpine_version in ${alpine_versions}; do
        while read -r IMAGE_TAG; do

            export image_tag="${IMAGE_TAG}-alpine${alpine_version}"

            if [[ "${IMAGE_TAG}" != "latest" ]] && crane ls "${image_registry}/${image_name}" | grep -q "${image_tag}"; then
                echo "${image_registry}/${image_name}:${image_tag} already exists..."
            else

                export ALPINE_VERSION="${alpine_version}"
                export GO_VERSION="${IMAGE_TAG}"
                export IMAGE_NAME="${image_name}"
                export IMAGE_REGISTRY="${image_registry}"
                export IMAGE_TAG="${GO_VERSION}"

                echo "Building ${image_registry}/${image_name}:${image_tag}..."
                docker buildx bake push --no-cache
            fi
        done < <(echo "${go_versions}")
    done
}

function terraform()
{
    local alpine_versions="$(sort -V .alpine-versions.txt)"
    local tf_versions="$(cat .tf-versions.txt | head -n +140 | sort -V)" # index head -n +140 rebuild
    local image_name="terraform"
    local image_registry="index.docker.io/cyayung804"

    export DATE="${date}"

    cd "src/${image_name}" || exit 1

    for alpine_version in ${alpine_versions}; do
        while read -r IMAGE_TAG; do

            export image_tag="${IMAGE_TAG}-alpine${alpine_version}"

            if [[ "${IMAGE_TAG}" != "latest" ]] && crane ls "${image_registry}/${image_name}" | grep -q "${image_tag}"; then
                echo "${image_registry}/${image_name}:${image_tag} already exists..."
            else
            
                export ALPINE_VERSION="${alpine_version}"
                export TF_VERSION="${IMAGE_TAG}"
                export IMAGE_NAME="${image_name}"
                export IMAGE_REGISTRY="${image_registry}"
                export IMAGE_TAG="${TF_VERSION}"

                echo "Building ${image_registry}/${image_name}:${image_tag}..."
                docker buildx bake push --no-cache
            fi
        done < <(echo "${tf_versions}")
    done
}

"$@"
