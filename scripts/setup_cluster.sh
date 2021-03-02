#!/bin/bash

set +x
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "Do not switch kubectl context before the end of this script!"

minikube addons enable metrics-server
minikube addons enable ingress

# Ensure we run on minikube
kubectl config use-context minikube

# Extract helm version
HVER=$(helm version || true)

if [[ $HVER == *"v2."* ]]; then # Helm 2
  # Install tiller
  helm init --wait --upgrade
else
  # Helm 3 comes without any repos
  helm repo add stable https://charts.helm.sh/stable
  helm repo update
fi
