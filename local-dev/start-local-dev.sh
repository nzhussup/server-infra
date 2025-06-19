#!bin/bash

echo "Starting local development environment..."

echo "Starting Minikube..."
minikube start

echo "Setting up base local environment..."
kubectl apply -f db.yml
kubectl apply -f auth-service.yml
cd ../k8s/services/admin-panel
kubectl apply -f api-gateway-deployment.yml
kubectl apply -f redis-deployment.yml
cd ../../config-secrets
kubectl apply -f configmap.yml