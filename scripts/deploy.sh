#!/bin/bash

# Set variables
NAMESPACE="anonymoose-prod"
DEPLOYMENT_NAME="anonymoose-deployment"
IMAGE="evilgenius13/anonymoose:prod"

# Export KUBECONFIG path
export KUBECONFIG=/home/ubuntu/.kube/config

# Debugging and clarity
pwd
ls -R

# Debugging step to ensure KUBECONFIG is set correctly
echo "Using KUBECONFIG: $KUBECONFIG"
kubectl config view

# Verify kubectl can connect to the cluster
kubectl get nodes

# Check if there are any changes in the deployment YAML files
git fetch origin main
if git diff --exit-code origin/main -- deployment/production; then
  echo "No changes in deployment YAML files, updating image..."
  # No changes, update the image
  kubectl set image deployment/${DEPLOYMENT_NAME} ${DEPLOYMENT_NAME}=${IMAGE} -n ${NAMESPACE}
else
  echo "Changes detected in deployment YAML files, applying changes..."
  # Apply Kubernetes manifests
  kubectl apply -f deployment/production/memcache_deployment.yml -n ${NAMESPACE}
  kubectl apply -f deployment/production/app_deployment.yml -n ${NAMESPACE}
fi
