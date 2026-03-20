# Platform Infrastructure

[![Kubernetes](https://img.shields.io/badge/Kubernetes-manifests-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![k3s](https://img.shields.io/badge/k3s-supported-FFC61C?style=for-the-badge&logo=k3s&logoColor=black)](https://k3s.io/)
[![Docker](https://img.shields.io/badge/Docker-local%20runtime-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Keycloak](https://img.shields.io/badge/Keycloak-IAM-4D4D4D?style=for-the-badge&logo=keycloak&logoColor=white)](https://www.keycloak.org/)
[![Redis](https://img.shields.io/badge/Redis-cache-DC382D?style=for-the-badge&logo=redis&logoColor=white)](https://redis.io/)
[![NGINX](https://img.shields.io/badge/NGINX-Ingress-009639?style=for-the-badge&logo=nginx&logoColor=white)](https://nginx.org/)
[![Let's_Encrypt](https://img.shields.io/badge/Let%27s%20Encrypt-TLS-003A70?style=for-the-badge&logo=letsencrypt&logoColor=white)](https://letsencrypt.org/)
[![GitHub_Actions](https://img.shields.io/badge/GitHub%20Actions-release%20automation-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)](https://github.com/features/actions)
[![Shell](https://img.shields.io/badge/Shell-automation-89E051?style=for-the-badge&logo=gnubash&logoColor=black)](https://www.gnu.org/software/bash/)

## Overview

This repository contains the infrastructure configuration for running the `nzhussup.dev` platform and related internal services. Its main purpose is to keep deployment configuration, ingress rules, TLS setup, persistence definitions, and local infrastructure helpers in one place.

The repository is operational in scope. It does not contain application business logic. Instead, it defines how services are exposed, secured, persisted, and started in the target environment.

## Purpose

The project serves as the infrastructure layer for the wider platform. It is used to:

- manage Kubernetes manifests for deployed services
- configure ingress and external routing
- handle HTTPS termination and certificate issuance
- define persistent storage used by stateful workloads
- document operational setup steps that are not part of application repositories

## Technology Scope

The repository currently centers on:

- Kubernetes manifests for runtime configuration
- k3s-compatible deployment structure
- NGINX Ingress configuration
- Let's Encrypt and cert-manager based TLS setup
- shell scripts for local and server-side operational tasks
- GitHub Actions for release automation

## Repository Structure

```text
.
├── k8s/
│   ├── services/              # Service and deployment manifests
│   ├── ingress/              # Ingress controller and routing rules
│   ├── https-encryption/     # TLS and certificate configuration
│   ├── persistence/          # Persistent volume definitions
│   └── discontinued-services/# Archived or no longer active manifests
├── docs/                     # Supporting operational documentation
├── scripts/                  # Utility and maintenance scripts
└── .github/workflows/        # Release workflow automation
```

## Main Areas

### Kubernetes Manifests

The `k8s/` directory contains the deployment-related resources used on the target cluster. This includes ingress resources, TLS configuration, persistence definitions, and service-specific manifests.

Infrastructure runtimes such as Redis are also defined here at manifest level instead of being built as custom application images.

Keycloak is deployed as its own service for platform IAM, while the realm template and startup logic live in the backend repository.

### Operational Scripts

The `scripts/` directory contains helper scripts for environment setup and maintenance tasks. These scripts are operational utilities and should be reviewed before execution in any non-local environment.

### Documentation

The `docs/` directory contains supporting setup notes, for example database-related operational guidance in [docs/db-setup.md](./docs/db-setup.md).

## Requirements

To use this repository effectively, the following tools or environments are expected:

- a Kubernetes cluster
- a k3s-compatible target environment if you want to mirror the current production approach
- `kubectl` access to the cluster
- Docker for local container-based development workflows

## Services

| Service           | Role                                           | Main Location                                                          |
| ----------------- | ---------------------------------------------- | ---------------------------------------------------------------------- |
| `NGINX Ingress`   | External routing and ingress controller config | `k8s/ingress/`                                                         |
| `Let's Encrypt`   | TLS issuer and certificate automation          | `k8s/https-encryption/`                                                |
| `Redis`           | Shared cache/runtime dependency                | `k8s/services/backend-services/backend-redis-server-deployment.yml`    |
| `Keycloak`        | IAM, realm import, and auth runtime            | `k8s/services/backend-services/backend-keycloak-server-deployment.yml` |
| `NGINX Gateway`   | Backend API entrypoint and path router         | `k8s/services/backend-services/backend-nginx-gateway-deployment.yml`   |
| `Base Service`    | Core application backend service               | `k8s/services/backend-services/backend-base-service-deployment.yml`    |
| `Image Service`   | Backend image/media service                    | `k8s/services/backend-services/backend-image-service-deployment.yml`   |
| `LLM Service`     | Backend LLM integration service                | `k8s/services/backend-services/backend-llm-service-deployment.yml`     |
| `Web Admin Panel` | Admin frontend runtime                         | `k8s/services/web-admin-panel/`                                        |
| `Web Portfolio`   | Public frontend runtime                        | `k8s/services/web-portfolio/`                                          |

## Release and Versioning

This repository also contains release automation and changelog support. Versioning and tagged release handling are managed through the workflow configuration in `.github/workflows/` and the release scripts stored in `.github/scripts/`.
