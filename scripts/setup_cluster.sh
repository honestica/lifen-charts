#!/bin/bash

set +x
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "Do not switch kubectl context before the end of this script!"

minikube addons enable metrics-server

# Ensure we run on minikube
kubectl config use-context minikube

curl https://docs.projectcalico.org/v3.8/manifests/calico.yaml -O
kubectl apply -f calico.yaml

# Create the namespace where this application will be deployed:

kubectl apply -f $DIR/cluster_setup.yaml 

# Install helm 

helm init --wait --upgrade

# Install calico

helm upgrade nginx-ingress-internal --set controller.ingressClass=nginx --set controller.service.enableHttps=false stable/nginx-ingress --install --kube-context minikube --namespace ingress