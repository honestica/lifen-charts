#!/bin/bash

set +x
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "Do not switch kubectl context before the end of this script!"

minikube addons enable metrics-server
minikube addons enable ingress

# Ensure we run on minikube
kubectl config use-context minikube

# Create the namespace where this application will be deployed:

kubectl apply -f $DIR/cluster_setup.yaml 

# Install helm

HVER=$(helm version || true)

if [[ $HVER == *"v2."* ]]; then
  helm init --wait --upgrade
else
  helm repo add stable https://kubernetes-charts.storage.googleapis.com/
  helm repo update
fi
