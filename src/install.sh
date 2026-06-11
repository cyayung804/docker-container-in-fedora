#!/bin/bash

set -e

function cleanup() {
    echo "  -> Cleaning up temporary files..."
    rm -rfv /tmp/go-containerregistry.tar.gz
}

function install_deps()
{
    echo "  -> Initializing ${FUNCNAME}..."

    $(which sudo) apt-get update
    $(which sudo) apt-get install -y curl git gzip tar make
}

function install_crane()
{
    local crane_version="0.21.3"
    arch="$(case "$(uname -m)" in x86_64) echo x86_64 ;; aarch64) echo arm64 ;; esac)"
    crane_download_url="https://github.com/google/go-containerregistry/releases/download/v${crane_version}/go-containerregistry_Linux_${arch}.tar.gz"

    echo "  -> Initializing ${FUNCNAME}..."

    trap cleanup EXIT INT TERM

    echo "  -> Downloading crane..."
    curl -fsSL "${crane_download_url}" > /tmp/go-containerregistry.tar.gz

    echo "  -> Unpacking crane..."
    $(which sudo) tar -zxvf /tmp/go-containerregistry.tar.gz -C /usr/local/bin/ crane
    $(which sudo) chmod +x /usr/local/bin/crane

    crane version
}

install_deps
install_crane
