# Kube-iptables-tailer
[Kube-iptables-tailer](https://github.com/box/kube-iptables-tailer) is a service for better visibility on networking issues in Kubernetes clusters.

## Prerequisites
- Kubernetes cluster with network policy support (optional but recommended).
- IPtables logging enabled on nodes. When using Calico the chart can enable the required logging rule.
- iptables logs must be written to a predictable file path and use RFC3339 timestamps for correct parsing.

## Add the repo

```bash
helm repo add lifen-charts http://honestica.github.io/lifen-charts/
```

## Usage on AWS EKS with managed nodes

We suppose you followed the EKS tutorial to install Calico: https://docs.aws.amazon.com/eks/latest/userguide/calico.html

Use the provided `values-eks.yaml` when targeting EKS.

## Examples
- Basic install using the example values shipped with the chart:

```bash
helm install kube-iptables-tailer ./kube-iptables-tailer -n kube-system -f examples/kube-iptables-tailer/values.yaml
```

## Configuration reference
See `values.yaml` for inline comments and more advanced options. The table below lists the values present in the chart's `values.yaml` and their defaults.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `image.repository` | string | `honestica/kube-iptables-tailer` | Container image repository |
| `image.tag` | string | `master-19` | Image tag used by the chart |
| `image.pullPolicy` | string | `IfNotPresent` | Image pull policy |
| `nameOverride` | string | `""` | Override chart name template |
| `fullnameOverride` | string | `""` | Override full resource names |
| `iptablesLogPrefix` | string | `calico-packet:` | Log prefix the tailer will filter for |
| `kubeApiServicer` | string | `https://kubernetes.default:443` | Address of the Kubernetes API server (used when kube-proxy discovery is not available) |
| `podAnnotations` | object | `{}` | Annotations applied to the pod (e.g., prometheus scrape) |
| `rbac.create` | bool | `true` | Create RBAC roles and bindings required by the chart |
| `serviceAccount.create` | bool | `true` | Create a ServiceAccount for the pod |
| `serviceAccount.name` | string | (empty) | Use an existing ServiceAccount name if provided |
| `calico.loggingEnable` | bool | `true` | When true the chart applies Calico rules to log dropped packets |
| `calico.apiVersion` | string | `projectcalico.org/v3` | Calico CRD API version to use for rule configuration (check your cluster with `kubectl api-versions`) |
| `resources` | object | `{}` | CPU/memory requests and limits for the container |
| `nodeSelector` | object | `{}` | Node selector for scheduling the pod |
| `tolerations` | list | `[]` | Pod tolerations for node taints |
| `affinity` | object | `{}` | Pod affinity/anti-affinity rules |

Notes:
- `iptablesLogPath` and `journalDirectory` are intentionally commented in `values.yaml`; enable exactly one of the file-based or journal-based logging options depending on how node logs are exposed.
- This chart no longer includes an embedded syslog sidecar in `values.yaml`; if you need syslog forwarding, either add a sidecar manually in `templates` or use a DaemonSet on the host to forward kernel logs into the expected file.

## On-node rsyslog configuration
If you use a host-level rsyslog to redirect kernel messages into a specific file (recommended when not adding a sidecar), add a `.conf` in `/etc/rsyslog.d/` like the following:

```
$template TemplateIptables,"%TIMESTAMP:::date-rfc3339% %hostname% %msg%\n"

:msg, contains, "calico-packet:" -/var/log/iptables.log;TemplateIptables
& ~
```

This routes messages containing the configured `iptablesLogPrefix` into `/var/log/iptables.log` using RFC3339 timestamps.

## Notes
- The example `examples/kube-iptables-tailer/values.yaml` is the canonical example for this chart. Adjust values to match your environment before installing.
- When enabling Calico logging, verify the `calico.apiVersion` matches the CRD version installed on your cluster.
