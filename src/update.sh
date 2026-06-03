#!/bin/bash

set -e

echo "==> Running $(dirname "$(realpath "$0")")/update.sh"

regex_minor_semver='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$'
regex_patch_semver='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$'

function alpine()
{
    local image_registry="public.ecr.aws/docker/library"
    local image_name="alpine"
    local count=0

    until latest_versions=$(crane ls "${image_registry}/${image_name}" 2>/dev/null | grep -E "${regex_minor_semver}" | sort -Vr) && [ -n "$latest_versions" ] || [ $count -eq 5 ]; do
        count=$((count + 1))
        echo "     Rate limited or empty response. Retrying ($count/5)..."
        sleep 5
    done

    echo "${latest_versions}" > .alpine-versions.txt
    cat .alpine-versions.txt | head -n 1 > .alpine-version
    echo ".alpine-version:"
    cat .alpine-version
    echo ".alpine-versions.txt:"
    cat .alpine-versions.txt
    cp -f .alpine-version src/alpine/.alpine-version || exit 1
    cp -f .alpine-versions.txt src/alpine/.alpine-versions.txt || exit 1
    cp -f .alpine-version src/golang/.alpine-version || exit 1
    cp -f .alpine-versions.txt src/golang/.alpine-versions.txt || exit 1
    cp -f .alpine-version src/terraform/.alpine-version || exit 1
    cp -f .alpine-versions.txt src/terraform/.alpine-versions.txt || exit 1
}

function golang()
{
    local image_registry="public.ecr.aws/docker/library"
    local image_name="golang"
    local count=0

    until latest_versions=$(crane ls "${image_registry}/${image_name}" 2>/dev/null | grep -E "${regex_patch_semver}" | sort -Vr) && [ -n "$latest_versions" ] || [ $count -eq 5 ]; do
        count=$((count + 1))
        echo "     Rate limited or empty response. Retrying ($count/5)..."
        sleep 5
    done

    echo "${latest_versions}" > .go-versions.txt
    cat .go-versions.txt | head -n 1 > .go-version
    echo ".go-version:"
    cat .go-version
    echo ".go-versions.txt:"
    cat .go-versions.txt
    cp -f .go-version src/golang/.go-version || exit 1
    cp -f .go-versions.txt src/golang/.go-versions.txt || exit 1
}

function terraform()
{
    local image_registry="public.ecr.aws"
    local image_name="hashicorp/terraform"
    local count=0

    until latest_versions=$(crane ls "${image_registry}/${image_name}" 2>/dev/null | grep -E "${regex_patch_semver}" | sort -Vr) && [ -n "$latest_versions" ] || [ $count -eq 5 ]; do
        count=$((count + 1))
        echo "     Rate limited or empty response. Retrying ($count/5)..."
        sleep 5
    done
    
    echo "${latest_versions}" > .tf-versions.txt
    cat .tf-versions.txt | head -n 1 > .tf-version
    echo ".tf-version:"
    cat .tf-version
    echo ".tf-versions.txt:"
    cat .tf-versions.txt
    cp -f .tf-version src/terraform/.tf-version || exit 1
    cp -f .tf-versions.txt src/terraform/.tf-versions.txt || exit 1
}

alpine
golang
terraform
