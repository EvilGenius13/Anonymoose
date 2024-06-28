#!/bin/bash

# Export KUBECONFIG if not already set
export KUBECONFIG=${KUBECONFIG:-~/.kube/config}

# Namespace
NAMESPACE="anonymoose-prod"

# Add a unique annotation to the deployment file to force Kubernetes to see it as updated
unique_id=$(date +%s)

sed -i "s/annotations:.*/annotations:\n      redeploy-hash: \"$unique_id\"/" app_deployment.yml

# Apply Kubernetes manifests
kubectl apply -f memcached_deployment.yml -n $NAMESPACE
kubectl apply -f app_deployment.yml -n $NAMESPACE
kubectl apply -f app_service.yml -n $NAMESPACE
kubectl apply -f pvc.yml -n $NAMESPACE
