## What is Qualytics?

Qualytics is a closed source container-native platform for assessing, monitoring, and ameliorating data quality for the Enterprise. Learn more [about our product and capabilities here](https://qualytics.co/product/).

## What is in this chart?

This chart will deploy a single-tenant instance of the qualytics platform to a [CNCF compliant](https://www.cncf.io/certification/software-conformance/) kubernetes control plane.

![Deployment Architecture](/deployment_arch_diagram.jpg)

## How should I use this chart?

Work with your account manager at Qualytics to securely obtain the appropriate values for your licensed deployment. If you don't yet have an account manager, [please write us here](mailto://hello@qualytics.co) to say hello! At minimum, you will need credentials for our Docker Private Registry and a set of Auth0 secrets that will be used in the following steps.

### 1. Create a CNCF compliant cluster

Qualytics fully supports kubernetes clusters hosted in AWS, GCP, and Azure as well as any CNCF compliant control plane.

#### Node Requirements

Node(s) with the following labels must be made available:
- `appNodes=true`
- `sparkNodes=true`

Nodes with the `sparkNodes=true` label will be used for Spark jobs and nodes with the `appNodes=true` label will be used for all other needs.  It is possible to provide a single node with both labels if that node provides sufficient resources to operate the entire cluster according to the specified chart values.  However, it is highly recommended to setup autoscaling for Apache Spark operations by providing a group of nodes with the `sparkNodes=true` label that will grow on demand.

|          |          Application Nodes          |                  Spark Nodes                    |
|----------|:-----------------------------------:|:-----------------------------------------------:|
| Label    | appNodes=true                       | sparkNodes=true                                 |
| Scaling  | Fixed (1 node on-demand)            | Autoscaling (2 - 11 nodes spot)                 |
| EKS      | t3.2xlarge                          | r5d.xlarge                                      |
| GKE      | n2-standard-8                       | c2d-highmem-4                                   |
| AKS      | Standard_D8_v5                      | Standard_E4s_v5                                 |

#### Docker Registry Secrets

Execute the command below using the credentials supplied by your account manager as replacements for "your-name" and "your-pword". The secret created will provide access to Qualytics private registry and the required images that are available there.

```bash
kubectl create namespace qualytics
kubectl create secret docker-registry regcred -n qualytics --docker-username=qualyticsread --docker-password=<token>
```

> [!IMPORTANT]
> If you are unable to directly connect your cluster to our image repository for technical or compliance reasons, then you can instead import our images into your preferred registry using these same credentials. You'll need to update the image URLs in the values.yaml file in the next step to point to your repository instead of ours.


### 2. Update values.yaml with appropriate values

Update `values.yaml` according to your requirements. At minimum, the "secrets" section at the top should be updated with the Auth0 settings supplied by your Qualytics account manager.

```bash
auth0_audience: changeme-api
auth0_organization: org_changeme
auth0_spa_client_id: spa_client_id
```

Contact your [Qualytics account manager](mailto://hello@qualytics.co) for assistance.

### 3. Deploy Qualytics to your cluster

The following command will first ensure that all chart dependencies are availble and then proceed with an installation of the Qualytics platform.

```bash
helm repo add qualytics https://qualytics.github.io/qualytics-helm-public
helm upgrade --install qualytics qualytics/qualytics --namespace qualytics --create-namespace -f values.yaml
```

As part of the install process, an nginx ingress will be configured with an inbound IP address. Make note of this IP address as it is needed for the fourth and final step!

### 4. Register your deployment's web application

Send your [account manager](mailto://hello@qualytics.co) the IP address for your cluster ingress gathered from step 3. Qualytics will assign a DNS record to it under `*.qualytics.io` so that your end users can securely access the deployed web application from a URL such as `https://acme.qualytics.io`

## Can I run a fully "air-gapped" deployment?

Yes. The only egress requirement for a standard self-hosted Qualytics' deployment is to https://auth.qualytics.io which provides Auth0 powered federated authentication. This is recommended for ease of installation and support, but not a strict requirement. If you have need of a fully private deployment with no access to the public internet, you can instead configure an OpenID Connect (OIDC) integration with your enterprise identity provider (IdP). Simply contact your Qualytics account manager for more details.

## Additional Documentation

- [Qualytics UserGuide](https://qualytics.github.io/userguide/)
