# docker-host-bootstrap

> Bootstrap a Linux host for Docker with engine install, Compose plugin, service enablement, and admin setup.

![Linux](https://img.shields.io/badge/Platform-Linux-blue?style=for-the-badge)
![Docker](https://img.shields.io/badge/Container-Docker-2496ED?style=for-the-badge)
![Automation](https://img.shields.io/badge/Focus-Host%20Bootstrap-orange?style=for-the-badge)

---

## Overview

`docker-host-bootstrap` is a Bash script that prepares a Linux server for Docker workloads.

It automates the common baseline tasks needed to get a host ready for containers, including Docker Engine installation, Docker Compose plugin setup, service enablement, and optional user group configuration.

---

## Features

- Detect Ubuntu and Debian
- Install Docker Engine
- Install Docker Compose plugin
- Install Docker Buildx plugin
- Enable and start Docker service
- Add a target user to the `docker` group
- Verify installation after bootstrap
- Suitable for fresh host preparation

---

## Use Cases

- New Linux server provisioning
- Docker host standardization
- Lab and test environment setup
- Admin portfolio demonstration
- Repeatable infrastructure bootstrap

---

## Supported Operating Systems

- Ubuntu
- Debian

---

## Requirements

- Root or `sudo` access
- Internet connectivity
- `apt`-based Linux distribution

---

## Installation

Clone the repository:

```bash
git clone https://github.com/I-MONDY-I/docker-host-bootstrap.git
cd docker-host-bootstrap
