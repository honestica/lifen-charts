# OP-SCIM Helm Chart

This is a Helm Chart for the 1Password SCIM Bridge for use with Helm based deployers.

## Helm Primer

This is a chart, a Helm package for a Helm Chart Repository  which contains all the resource definitions necessary to run op-scim inside of a Kubernetes cluster. More information on the structure of this package and the roles of the components can be found here: [https://helm.sh/docs/topics/charts/](https://helm.sh/docs/topics/charts/)

At the time of writing, the following is the package structure.

```
op-scim
│       ├── Chart.yaml
│       ├── templates
│       │   ├── application.yaml
│       │   ├── op-scim.yaml
│       │   └── redis.yaml
│       └── values.yaml
```


Generally the Chart.yaml describes the chart as a whole, the values.yaml provides default configuration values, and the templates can be combined with the values to produce valid Kubernetes manifests.

We have three templates: 
- application.yaml -> Overarching application description. Includes high level user facing details such as description and maintainer links and a raw logo image. 
- op-scim.yaml -> op-scim service description. Includes networking details, persistent volume connections, and startup arguments.
- redis.yaml -> redis service description. Includes basic redis details and networking connection to the op-scim service.
