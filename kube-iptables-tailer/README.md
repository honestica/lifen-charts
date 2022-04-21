# Kube-iptables-tailer
[Kube-iptables-tailer](https://github.com/box/kube-iptables-tailer) is a service for better visibility on networking issues in Kubernetes clusters.

## Prerequisites
-   Kubernetes with networkpolicy
-   Logs of iptable must be activated (handled by the chart in case of Calico)
-   Logs of iptable should be written to a specific file
-   Logs of iptable must be written using rfc3339 for the timestamp

## Add the repo

```
$ helm repo add lifen-charts http://honestica.github.io/lifen-charts/
```

## Usage on AWS EKS with managed nodes

We suppose you followed the EKS tutorial to install calico. https://docs.aws.amazon.com/eks/latest/userguide/calico.html

Use the provided `values-eks.yaml`

## Customization
The following options are supported.  See [values.yaml](values.yaml) for more detailed documentation and examples:

| Parameter                                   | Description                                                                                                                                                                                                                                                                                               | Default |
|---------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------|
| `calico.loggingEnable`                     | Whether to enable global logging of iptable dropped packet with Calico.                                                                                                                                                                                                        | `true`  |
| `calico.apiVersion`                     | Version of calico crds. Check yours with `kubectl api-versions`. When using calico tigera operator, this should be "projectcalico.org/v1"                                                                                                                                                                                                        | `projectcalico.org/v3`  |
| `serviceAccount.create`                     | Whether to create a Kubernetes ServiceAccount if no account matching `serviceAccount.name` exists.                                                                                                                                                                                                        | `true`  |
| `serviceAccount.name`                       | Name of the Kubernetes ServiceAccount under which Kube-iptables-tailer should run. If no value is specified and `serviceAccount.create` is `true`, Kube-iptables-tailer will be run under a ServiceAccount whose name is the FullName of the Helm chart's instance, else Kube-iptables-tailer will be run under the `default` ServiceAccount. | n/a     |
| `iptablesLogPath`                       | Absolute path to your iptables log file including the full file name. Should be "/var/log/kern.log" if your are not redirecting logs to a specific file. | "/var/log/iptables.log"     |
| `journalDirectory`                       | Absolute path to the folder of the journal directory. | "/var/log/journal"     |
| `iptablesLogPrefix`                       |  Log prefix defined in your iptables chains. The service will only handle the logs matching this log prefix exactly. | "calico-packet:"     |
| `kubeApiServicer`                       | Address of the Kubernetes API server. By default, the discovery of the API server is handled by kube-proxy. If kube-proxy is not set up, the API server address must be specified with this environment variable. Authentication to the API server is handled by service account tokens. See Accessing the Cluster for more info. | "https://kubernetes.default:443"    |


# On the VM ask rsyslog to forward the logs to /var/log/iptables.log

Add a .conf in /etc/rsyslog.d/ like the following:

```
$template TemplateIptables,"%TIMESTAMP:::date-rfc3339% %hostname% %msg%\n"

:msg, contains, "calico-packet:" -/var/log/iptables.log;TemplateIptables
& ~
```
