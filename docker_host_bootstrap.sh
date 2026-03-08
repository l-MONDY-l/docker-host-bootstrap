#!/usr/bin/env bash

# ==========================================================
# Docker Host Bootstrap
# Author: Ushan Perera
# Description:
# Prepares a Linux host for Docker workloads
# Supported:
#   - Ubuntu
#   - Debian
# ==========================================================

set -euo pipefail

TARGET_USER="${1:-${SUDO_USER:-}}"

line() {
    printf '%*s\n' "${COLUMNS:-70}" '' | tr ' ' '='
}

section() {
    echo
    line
    echo "$1"
    line
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        echo "This script must be run as root or with sudo."
        exit 1
    fi
}

detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS_ID="${ID:-unknown}"
        OS_VERSION="${VERSION_ID:-unknown}"
    else
        echo "Cannot detect operating system."
        exit 1
    fi
}

install_prerequisites() {
    apt-get update
    apt-get install -y ca-certificates curl gnupg lsb-release
}

setup_docker_repo() {
    install -m 0755 -d /etc/apt/keyrings

    if [[ ! -f /etc/apt/keyrings/docker.asc ]]; then
        curl -fsSL "https://download.docker.com/linux/${OS_ID}/gpg" -o /etc/apt/keyrings/docker.asc
        chmod a+r /etc/apt/keyrings/docker.asc
    fi

    ARCH="$(dpkg --print-architecture)"
    CODENAME="$(
        . /etc/os-release
        echo "${VERSION_CODENAME}"
    )"

    echo \
      "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/${OS_ID} \
      ${CODENAME} stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt-get update
}

install_docker_packages() {
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

enable_services() {
    systemctl enable docker
    systemctl start docker
}

add_user_to_docker_group() {
    local user="$1"

    if [[ -n "${user}" ]] && id "${user}" >/dev/null 2>&1; then
        usermod -aG docker "${user}"
        log "Added user '${user}' to docker group."
        log "User must re-login for group changes to take effect."
    else
        log "No valid target user provided. Skipping docker group assignment."
    fi
}

verify_install() {
    docker --version
    docker compose version
    systemctl is-active docker
}

main() {
    require_root
    detect_os

    section "DOCKER HOST BOOTSTRAP"
    log "Hostname      : $(hostname)"
    log "OS            : ${OS_ID}"
    log "Version       : ${OS_VERSION}"
    log "Target user   : ${TARGET_USER:-not provided}"

    case "${OS_ID}" in
        ubuntu|debian)
            section "INSTALLING PREREQUISITES"
            install_prerequisites

            section "CONFIGURING DOCKER REPOSITORY"
            setup_docker_repo

            section "INSTALLING DOCKER ENGINE"
            install_docker_packages
            ;;
        *)
            echo "Unsupported OS: ${OS_ID}"
            echo "This script currently supports Ubuntu and Debian only."
            exit 1
            ;;
    esac

    section "ENABLING DOCKER SERVICE"
    enable_services

    section "ADDING USER TO DOCKER GROUP"
    add_user_to_docker_group "${TARGET_USER:-}"

    section "VERIFYING INSTALLATION"
    verify_install

    section "BOOTSTRAP COMPLETE"
    log "Docker host bootstrap completed successfully."
}

main "$@"
