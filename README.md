# Lifen Charts

Welcome to the repository of Helm charts maintained by Lifen.

## List of Charts

* [alert2jira](alert2jira)
* [awx](awx)
* [kube-iptables-tailer](kube-iptables-tailer)
* [op-scim-bridge](op-scim-bridge)
* [squid](squid)
* [DEPRECATED] teleport : use official one from https://github.com/gravitational/teleport/tree/master/examples/chart/teleport
* [DEPRECATED] neuvector : use official one from https://github.com/neuvector/neuvector-helm


## Add the repo

```
$ helm repo add lifen-charts http://honestica.github.io/lifen-charts/
```

## Install the charts

You can use the usual commands `helm fetch/install lifen-charts/kube-iptables-tailer`.

Look at the Readme inside each directory :)

## Develop charts


## Start Minikube

Follow https://kubernetes.io/docs/tasks/tools/install-minikube/

## Install kubectl

Follow https://kubernetes.io/docs/tasks/tools/install-kubectl/

You should be able to see minikube node and pods:
```
$ kubectl get node
NAME       STATUS   ROLES    AGE   VERSION
minikube   Ready    master   63m   v1.15.0

$ kubectl get pod --all-namespaces
NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
kube-system   coredns-5c98db65d4-5xshj           1/1     Running   0          63m
kube-system   coredns-5c98db65d4-thf7p           1/1     Running   0          63m
kube-system   etcd-minikube                      1/1     Running   0          62m
kube-system   kube-addon-manager-minikube        1/1     Running   0          62m
kube-system   kube-apiserver-minikube            1/1     Running   0          62m
kube-system   kube-controller-manager-minikube   1/1     Running   0          62m
kube-system   kube-proxy-fcbsl                   1/1     Running   0          63m
kube-system   kube-scheduler-minikube            1/1     Running   0          62m
kube-system   storage-provisioner                1/1     Running   0          63m
```

## Install helm cli

Follow INSTALLING THE HELM CLIENT
from https://helm.sh/docs/using_helm/#installing-helm

# AWX chart

helm upgrade awx ./awx/ --install  --timeout 500 --wait -f examples/awx/values.yaml --kube-context minikube --namespace awx

Start minikube tunnel

Add in /etc/hosts
```
{{ external ip for private ingress }} http://awx.minikube
```
