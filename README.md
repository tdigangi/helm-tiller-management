## Tiller configuration
In order to securely utilize helm the tiller will need configured with and will have to be installed with the following arguments `helm init --tiller-namespace <ns> --kube-context <cluster-id> --service-account <service-account>`
- It would be a best practice to install [Tls certs](https://medium.com/google-cloud/install-secure-helm-in-gke-254d520061f7)
- tls certs installed will need a automated pipeline created to programmatically rotate certs
- tiller installed on each namespace, currently we propose using the same certs for all namespaces as this is simply the deployment of k8s components in GKE cluster
- tiller requires a service account to pull containers on rbac enabled GKE custer. Installation instructions can be found [here](https://medium.com/@elijudah/configuring-minimal-rbac-permissions-for-helm-and-tiller-e7d792511d10). Only allow specific users access to update/change service accounts.

### RBAC documentation
https://docs.helm.sh/using_helm/#tiller-and-role-based-access-control

### Tiller installation approach
1. In the new cluster create a namespace for central management of your cluster with out of the box kubectl manifest files.
- `kubectl create -f master-namespaces/manifests/tiller`
- `kubectl create -f master-namespaces/manifests/robot`

## Building charts
- create a gcs bucket that will be used for the chart repo
- install gcs plugin [helm-gcs](https://github.com/nouney/helm-gcs)

## Deploying
when releasing the chart and overwriting you have 3 possible solutions
- overwriting namespace via cmd line:
`helm install <chart> --set namespace_name=<name> --tiller-namespace <ns>`
- overwriting namespace via packaged install and external values file
```
helm install -f ./values-helm-playground.yaml acme-namespace-0.1.0.tgz --tiller-namespace <ns>`
```
- overwriting namespace via unpackaged install:
```
cd /path/to/acme-namespace
helm install -f values-helm-playground.yaml . --tiller-namespace <ns>`
```

### demo commands
#### Admin
- `gcloud auth application-default login` login as demo@demo.com
- `gcloud container clusters get-credentials mycluster`
- `kubectl get pods -n default`
- `./helpers/gke-context-user.sh`
- `kubectl get ns`
- `kubectl create -f manifests/tiller`
- `kubectl create -f manifests/robot`
- `kubectl delete serviceaccounts default -n helm-mgmt`
- `helm init --service-account tiller --tiller-namespace helm-mgmt`

#### Robot
- `gcloud auth application-default login` login as robot@demo.com
- `gcloud container clusters get-credentials mycluster`
- `kubectl get pods`
- `./helpers/gke-context-user.sh`
- `helm install -f values-helm-playground.yaml . --tiller-namespace=helm-mgmt`
- `cd ./demo-developer-app`
- `helm install . --tiller-namespace=helm-mgmt`
- `kubectl get deployments -n helm-mgmt`

#### Developer
- `gcloud auth application-default login` login as developer@demo.com
- `gcloud container clusters get-credentials mycluster`
- `kubectl get pods -n helm-mgmt`
- `kubectl get pods -n helm-playground`
- `helm install . --tiller-namespace=helm-mgmt` fails
