#!/bin/bash

# Set variables
REPO_URL="https://github.com/EvilGenius13/Anonymoose.git"
REPO_DIR="Anonymoose"
NAMESPACE="anonymoose-prod"
DEPLOYMENT_NAME="anonymoose-deployment"
CONTAINER_NAME="anonymoose"
IMAGE="evilgenius13/anonymoose:prod"

# Export KUBECONFIG path
export KUBECONFIG=/home/ubuntu/.kube/config

# Check if the repository already exists
if [ -d "$REPO_DIR" ]; then
  echo "Repository already exists. Pulling the latest changes..."
  cd $REPO_DIR
  git pull origin main
else
  echo "Cloning the repository..."
  git clone $REPO_URL
  cd $REPO_DIR
fi

# Debugging and clarity
pwd
ls -R

# Print the contents of the KUBECONFIG file
echo "Contents of KUBECONFIG ($KUBECONFIG):"
cat $KUBECONFIG

# Debugging step to ensure KUBECONFIG is set correctly
echo "Using KUBECONFIG: $KUBECONFIG"
kubectl config view

# Print the current context
echo "Current context:"
kubectl config current-context

# Verify kubectl can connect to the cluster
echo "Getting nodes:"
kubectl get nodes

# Check if there are any changes in the deployment YAML files
git fetch origin main
if git diff --exit-code origin/main -- deployment/production; then
  echo "No changes in deployment YAML files, updating image..."
  # No changes, update the image
  kubectl set image deployment/${DEPLOYMENT_NAME} ${CONTAINER_NAME}=${IMAGE} -n ${NAMESPACE}
else
  echo "Changes detected in deployment YAML files, applying changes..."
  # Apply Kubernetes manifests
  kubectl apply -f deployment/production/memcache_deployment.yml -n ${NAMESPACE}
  kubectl apply -f deployment/production/app_deployment.yml -n ${NAMESPACE}
fi
