# Server Infrastructure Config

This repository contains Kubernetes configuration files for managing deployments on my master server.
My master server is itself a worker server because I'm too broke to aford EKS by AWS or any other service 😭

## Structure

- **k8s/** – Main Kubernetes manifests for services, ingress, secrets, and persistent volumes.

  - `config-secrets/` – ConfigMaps and Secrets
  - `https-encryption/` – TLS/SSL setup with Let's Encrypt
  - `ingress/` – Ingress rules and network policies
  - `persistence/` – Persistent volume configurations
  - `services/` – Deployment files for all hosted services

- **local-dev/** – Configs and scripts to run a minimal local development environment.

## Notes

This setup is tailored for personal projects and services hosted on a master server using Kubernetes.

## Requirements

- Any Kubernetes distro. On my server it's k3s.
- Minikube for local development.
