# demo-developer-app

## Tiller configuration
In order to securely utilize helm the tiller will need configured with and will have to be installed with the following arguments `helm init --tiller-namespace <ns> --kube-context <cluster-id> --service-account <service account>`
- It would be a best practice to install [Tls certs](https://medium.com/google-cloud/install-secure-helm-in-gke-254d520061f7)
- tls certs installed will need a automated pipeline created to programmatically rotate certs
- tiller installed on each namespace, currently we propose using the same certs for all namespaces as this is simply the deployment of k8s components in GKE cluster
- tiller requires a service account to pull containers on rbac enabled GKE custer. Installation instructions can be found [here](https://medium.com/@elijudah/configuring-minimal-rbac-permissions-for-helm-and-tiller-e7d792511d10). Only allow specific users access to update/change service accounts.

### Tiller installation approach
1. In the new cluster create a namespace for central management of your cluster with out of the box kubectl manifest files.
- `kubectl create -f manifests/tiller-mgmt-ns.yaml`
- `kubectl create -f manifests/tiller-mgmt-sa.yaml`
- `kubectl create -f manifests/tiller-mgmt-rolebindings.yaml`

## Building & Deploying helm charts
### Create chart repo
- create the chart repo bucket `gsutl mb gs://<bucket-name>`
- install gcs plugin [helm-gcs](https://github.com/nouney/helm-gcs) on the deployment platform(I.E Jenkins)
- `helm gcs init gs://bucket/path`


### Building
- Configure the Chart.yml with the correct information for the release, pay specific attention to the chart version.
- `helm package chart`
- `helm gcs push chart.tar.gz repo-name`

### Deploying
Provide the helm deployment server with the correct cluster context for helm deployment:
- `gcloud container clusters get-credentials <cluster>`
- `kubectl config current-context`
- `helm fetch repo-name/chart`
- `helm install -f myvalues.yaml <chart> --tiller-namespace <ns>`


## Gotchas
- helm is very reliant on the proper indentation and formatting for functions. Ensure you are indenting within the functions below and they are in the first column of the line. See example below
```
{{- if .Values.extraEnv }}
{{ toYaml .Values.extraEnv | indent 12 }}
{{- end }}
```
- You will need cluster admin priv in order to create roles. `kubectl create clusterrolebinding test-cluster-admin-binding --clusterrole=cluster-admin --user=test@test.com`

- Example of conditional functions can be found [here](https://hackernoon.com/the-art-of-the-helm-chart-patterns-from-the-official-kubernetes-charts-8a7cafa86d12).


## Secrets configuration
https://lab.getbase.com/helm-secrets-a-missing-piece-in-kubernetes/
https://github.com/futuresimple/helm-secrets

### References
https://container-solutions.com/kubernetes-deployment-strategies/
