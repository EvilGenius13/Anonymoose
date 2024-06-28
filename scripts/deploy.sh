#!/bin/bash

# Debugging
pwd
ls -R

# Export KUBECONFIG if not already set
export KUBECONFIG=${KUBECONFIG:-~/.kube/config}

# Namespace
NAMESPACE="anonymoose-prod"

# Add a unique annotation to the deployment file to force Kubernetes to see it as updated
unique_id=$(date +%s)

# Update the deployment file with a unique annotation
sed -i "s/annotations:.*/annotations:\n      redeploy-hash: \"$unique_id\"/" deployment/production/app_deployment.yml

# Apply Kubernetes manifests
kubectl apply -f deployment/production/memcache_deployment.yml -n $NAMESPACE
kubectl apply -f deployment/production/app_deployment.yml -n $NAMESPACE
