#!/bin/bash

# Debugging and clarity
pwd
ls -R

# Export KUBECONFIG if not already set
export KUBECONFIG=${KUBECONFIG:-~/.kube/config}

# Debugging step to ensure KUBECONFIG is set correctly
echo "Using KUBECONFIG: $KUBECONFIG"
kubectl config view

# Set the correct context (optional but ensures the correct context is used)
kubectl config use-context microk8s

# Verify kubectl can connect to the cluster
kubectl get nodes

# Namespace
NAMESPACE="anonymoose-prod"

# Apply Kubernetes manifests
echo "Applying memcache deployment"
kubectl apply -f deployment/production/memcache_deployment.yml -n $NAMESPACE --validate=false

echo "Applying app deployment"
kubectl apply -f deployment/production/app_deployment.yml -n $NAMESPACE --validate=false
