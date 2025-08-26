# Looker

Looker is a cloud-based business intelligence (BI) platform designed to explore and analyze data.

This Helm chart deploys Looker on Kubernetes. The default image is `honestica/looker`. Building your own image requires a valid Looker license and the image sources in https://github.com/honestica/docker-looker.

## Prerequisites

- A Kubernetes cluster and `helm` (v3+).
- A valid Looker license for building/using the Looker image.
- If you want a stateless deployment, an external database (MySQL/Postgres) reachable from the cluster.
- A StorageClass if you enable `persistence`.

## Quick install

Install the chart from the repository root (locally):

```bash
helm install my-looker ./looker --namespace looker --create-namespace
```

Install with a custom values file:

```bash
helm install my-looker ./looker -n looker -f my-values.yaml
```

Set an image tag inline:

```bash
helm upgrade --install my-looker ./looker -n looker --set image.tag=2.16.0
```

## Important configuration notes

- Persistence

  - `persistence.enabled` is `false` by default. When disabled Looker stores data in-memory and state will be lost on pod restart.
  - To keep data across restarts enable `persistence.enabled: true` and tune `persistence.storageSize` and `persistence.storageClass`.

- Database

  The chart supports three ways to provide database configuration. Choose the one that fits your security and operational model.

  1) Inline values (recommended for quick testing)

     - Set `values.database.*` fields directly in `values.yaml` (dialect, host, username, password, database, port).

     Example:

     ```yaml
     database:
       dialect: mysql
       host: mydb.example.local
       username: looker
       password: s3cr3t
       database: looker
       port: 3306
     ```

  2) Kubernetes secret containing `looker-db.yml` (file-based config)

     - Create a secret that contains the full `looker-db.yml` file and set `databaseConfigSecretName` to the secret name.

     Example:

     ```bash
     kubectl create secret generic looker-db-secret --from-file=looker-db.yml=./looker-db.yml -n looker
     # then in values.yaml set databaseConfigSecretName: looker-db-secret
     ```

     - This method is useful when you prefer to provide Looker with a file config instead of env vars.

  3) AWS Secrets Manager via ExternalSecret (recommended for secret-managed environments)

     - The chart includes a template `templates/externalsecret.yaml` that creates an `ExternalSecret` (External Secrets Operator) which fetches database credentials from AWS Secrets Manager and builds a Kubernetes secret containing `looker-db.yml`.
     - To use this option set `database.secret_store_key_arn` to the ARN (or key) of the secret in AWS Secrets Manager.
     - The ExternalSecret in this chart expects a ClusterSecretStore named `aws-secretmanager-infra` by default. You can change the `secretStoreRef` in `templates/externalsecret.yaml` if your ClusterSecretStore has a different name.

     Example `values.yaml` snippet:

     ```yaml
     database:
       secret_store_key_arn: "arn:aws:secretsmanager:eu-west-1:123456789012:secret:my-looker-db-ABC123"
     ```

     What happens when enabled:

     - The ExternalSecret will fetch the remote secret and map its `looker/database_pass` property to `database_pass` in the created Kubernetes secret.
     - The template then renders a `looker-db.yml` from the provided `database.*` fields and the fetched `database_pass` into the secret's `looker-db.yml` data key.

     Requirements:

     - The External Secrets Operator (v1beta1) must be installed in the cluster and a ClusterSecretStore configured to access AWS Secrets Manager (the chart assumes `aws-secretmanager-infra`).
     - Proper RBAC and IAM permissions must be configured for the External Secrets Operator to read the secret in AWS.

- Extra environment / JVM / Looker args

  - `extraEnvs` is appended to the container `env:` configuration.
  - By default the chart sets `LOOKEREXTRAARGS` to `--shared-storage-dir=/data/` (see `values.yaml`). If you use a local DB config file, add `-d /home/looker/looker-db.yml` to that variable.

- Probes and startup time

  - The chart provides liveness, readiness and startup probes. The default `initialDelaySeconds` for the liveness probe is high (600s) to allow Looker to complete initialization. If your environment differs, tune the probe values in `values.yaml`.

- Security

  - The chart enforces non-root execution and drops capabilities by default (`securityContext` and `podSecurityContext` values). Review these settings if your environment requires different permissions.

## Examples

Enable persistence and configure an external DB (`my-values.yaml`):

```yaml
persistence:
  enabled: true
  storageSize: 10Gi

database:
  dialect: mysql
  host: mydb.cluster.local
  username: looker
  password: s3cr3t
  database: looker
```

## Troubleshooting

- Check pod status and logs:

```bash
kubectl -n looker get pods
kubectl -n looker logs <pod-name>
```

- If Looker cannot connect to the DB:
  - Verify `database.host`, `database.username`, `database.password`, `database.port` and network access (NetworkPolicy, service names).
  - If using a secret for `looker-db.yml`, confirm the secret name and contents.
  - If using AWS Secrets Manager, ensure the External Secrets Operator has access to the secret and that the ClusterSecretStore referenced in `templates/externalsecret.yaml` points to your AWS credentials provider.

- If the application never becomes ready, check the startup probe timing and container logs; Looker can take several minutes to initialize.

## Where to go next

- Docker image and build instructions: https://github.com/honestica/docker-looker
- Chart sources: https://github.com/honestica/lifen-charts/tree/master/looker

## Values reference

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of Looker replicas (pods) |
| image.repository | string | `"honestica/looker"` | Container image repository |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.tag | string | `""` | Image tag; when empty chart's appVersion is used |
| imagePullSecrets | list | `[]` | Pull secrets for private registries |
| nameOverride | string | `""` | Override chart name template |
| fullnameOverride | string | `""` | Override full resource names |
| additionalLabels | object | `{}` | Extra labels applied to resources |
| probes.livenessProbe.initialDelaySeconds | int | `600` | Liveness probe initial delay (seconds) |
| probes.livenessProbe.failureThreshold | int | `10` | Liveness probe failure threshold |
| probes.livenessProbe.httpGet.path | string | `/alive` | Liveness probe HTTP path |
| probes.readinessProbe.httpGet.path | string | `/alive` | Readiness probe HTTP path |
| probes.startupProbe.failureThreshold | int | `30` | Startup probe failure threshold |
| extraEnvs[0].name | string | `"LOOKEREXTRAARGS"` | Additional env var used for Looker startup args |
| extraEnvs[0].value | string | `"--shared-storage-dir=/data/"` | Default extra args (shared storage); append DB config flags if needed |
| database.dialect | string | `mysql` | Database dialect (mysql/postgres) |
| database.host | string | `""` | Database host (empty = in-memory DB) |
| database.username | string | `""` | Database username |
| database.password | string | `""` | Database password |
| database.database | string | `""` | Database name |
| database.port | int | `3306` | Database port |
| database.ssl.enabled | bool | `false` | Enable SSL for DB connections |
| database.ssl.serverCert | string | `''` | Optional server certificate path or PEM to use when connecting securely |
| database.secret_store_key_arn | string | `""` | (Optional) AWS Secrets Manager secret ARN/key used by ExternalSecret to fetch `looker/database_pass` and populate the generated `looker-db.yml` secret |
| database.secret_store_key_arn (notes) | string | n/a | Requires External Secrets Operator and a ClusterSecretStore (default `aws-secretmanager-infra`) configured to access AWS Secrets Manager |
| databaseConfigSecretName | string | (unset) | Name of secret that contains a full `looker-db.yml` file |
| serviceAccount.create | bool | `true` | Create a ServiceAccount for the pod |
| serviceAccount.name | string | `""` | ServiceAccount name to use (if not creating one) |
| persistence.enabled | bool | `false` | Enable persistent volume for Looker data |
| persistence.storageSize | string | `10Gi` | PVC size when persistence enabled |
| persistence.accessMode | string | `ReadWriteOnce` | PVC access mode |
| podAnnotations | object | `{}` | Annotations applied to the pod |
| podSecurityContext.fsGroup | int | `2000` | fsGroup applied to pod volumes |
| securityContext.runAsNonRoot | bool | `true` | Run container as non-root |
| securityContext.runAsUser | int | `1000` | UID to run the container as |
| securityContext.runAsGroup | int | `2000` | GID to run the container as |
| securityContext.readOnlyRootFilesystem | bool | `true` | Enforce read-only root filesystem |
| securityContext.allowPrivilegeEscalation | bool | `false` | Allow privilege escalation |
| securityContext.capabilities.drop | list | `["ALL"]` | Capabilities dropped from the container |
| service.type | string | `ClusterIP` | Kubernetes Service type (ClusterIP/NodePort/LoadBalancer) |
| ingress.enabled | bool | `false` | Enable Ingress to expose Looker |
| ingress.hosts[0].host | string | `"chart-example.local"` | Example host used when ingress is enabled |
| ingress.tls | list | `[]` | TLS configuration for ingress hosts |
| additionalIngresses | object | `{}` | Define multiple extra ingresses if needed |
| ingressApi.enabled | bool | `false` | Enable a second ingress for API endpoints |
| ingressHealthcheck.enabled | bool | `false` | Enable a dedicated ingress for healthchecks |
| networkPolicies.enabled | bool | `false` | Enable NetworkPolicy resources |
| networkPolicies.dbRanges.mysql | list | `[]` | Allowed CIDR ranges for MySQL access (when networkPolicies enabled) |
| backup.enabled | bool | `false` | Chart-level backup toggle (implementation dependent) |
| resources | object | `{}` | CPU/memory requests and limits for the container |
| autoscaling.enabled | bool | `false` | Enable Horizontal Pod Autoscaler |
| autoscaling.minReplicas | int | `1` | Minimum replicas for HPA |
| autoscaling.maxReplicas | int | `100` | Maximum replicas for HPA |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization for HPA |
| nodeSelector | object | `{}` | Node selector for schedule constraints |
| tolerations | list | `[]` | Pod tolerations for taints |
| affinity | object | `{}` | Pod affinity/anti-affinity rules |

See the `values.yaml` in the chart folder for inline comments and additional advanced options.
