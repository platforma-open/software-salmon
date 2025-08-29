#!/usr/bin/env bash

set -o errexit
set -o nounset

script_dir="$(cd "$(dirname "${0}")" && pwd)"

base_url="https://github.com/COMBINE-lab/salmon/releases/download"

if [ "$#" -ne 3 ]; then
    echo "Usage: '${0}' <version> <os> <arch>"
    echo "Example: '${0}' 1.10.0 linux x64"
    echo "OS list: linux, windows, macosx"
    echo "Arch list: x64, aarch64"
    exit 1
fi

version="${1}"
os="${2}"
arch="${3}"
dst_root="dld"
dst_data_dir="${dst_root}/${os}-${arch}"

# Simplified arch and ext determination
case "${arch}" in
    "arm64"|"aarch64") 
        arch="arm64"
        dl_arch="aarch64"
    ;;
    "amd64"|"x86_64"|"x64")
        arch="x64"
        dl_arch="x86_64"
    ;;
    *) echo "Unknown arch: ${arch}"; exit 1 ;;
esac

case "${os}" in
    "linux"|"macosx") ext="tar.gz" ;;
    "windows") ext="zip" ;;
    *) echo "Unknown OS: ${os}"; exit 1 ;;
esac

dst_archive_path="${dst_root}/${version}-${os}-${arch}.${ext}"

# Simplify directory creation and exit early for specific unsupported combinations
mkdir -p "${dst_data_dir}"

log() {
    printf "%s\n" "$@"
}

download() {
    local url="${base_url}/v${version}/salmon-${version}_${os}_${dl_arch}.${ext}"
    local show_progress=()

    # Only add --show-progress if CI is not set to 'true'
    if [ "${CI:-false}" != "true" ]; then
        show_progress=("--show-progress")
    fi

    log "Downloading '${url}'"
    wget --quiet "${show_progress[@]}" --output-document="${dst_archive_path}" "${url}"
}

unpack() {
    log "Unpacking archive for ${os} to '${dst_data_dir}'"

    rm -rf "${dst_data_dir}"
    mkdir -pv "${dst_data_dir}"

    tar --strip-components=1 -xf "${dst_archive_path}" -C "${dst_data_dir}"
}

mkdir -p "${dst_root}"
download
unpack
