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
  git pull origin main || exit 1
else
  echo "Cloning the repository..."
  git clone $REPO_URL || exit 1
  cd $REPO_DIR
fi

# Apply Kubernetes manifests
echo "Applying Kubernetes manifests..."
kubectl apply -f deployment/production/minio-pv-pvc.yml -n ${NAMESPACE} || exit 1
kubectl apply -f deployment/production/memcache_deployment.yml -n ${NAMESPACE} || exit 1
kubectl apply -f deployment/production/minio_deployment.yml -n ${NAMESPACE} || exit 1
kubectl apply -f deployment/production/app_deployment.yml -n ${NAMESPACE} || exit 1

# Update the deployment image
echo "Updating deployment image..."
kubectl set image deployment/${DEPLOYMENT_NAME} ${CONTAINER_NAME}=${IMAGE} -n ${NAMESPACE} || exit 1

# Optional: restart the deployment to ensure it picks up the new image
kubectl rollout restart deployment/${DEPLOYMENT_NAME} -n ${NAMESPACE} || exit 1

echo "Deployment successful!"
exit 0
