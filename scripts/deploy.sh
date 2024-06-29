#!/bin/bash

# Debugging
pwd
ls -R

# Export KUBECONFIG if not already set
export KUBECONFIG=${KUBECONFIG:-~/.kube/config}

# Debugging
kubectl config view

# Namespace
NAMESPACE="anonymoose-prod"

# Apply Kubernetes manifests
kubectl apply -f deployment/production/memcache_deployment.yml -n $NAMESPACE
kubectl apply -f deployment/production/app_deployment.yml -n $NAMESPACE
