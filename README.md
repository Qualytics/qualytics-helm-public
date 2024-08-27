## What is Qualytics?

Qualytics is a closed-source container-native platform for assessing, monitoring, and facilitating enterprise data quality. Learn more [about our product and capabilities here](https://qualytics.co/product/).

## What is in this chart?

This chart will deploy a single-tenant instance of the qualytics platform to a [CNCF compliant](https://www.cncf.io/certification/software-conformance/) kubernetes control plane.

![Deployment Architecture](/deployment_arch_diagram.jpg)

## How should I use this chart?

Please work with your account manager at Qualytics to secure the right values for your licensed deployment. If you don't yet have an account manager, [please write us here](mailto://hello@qualytics.co) to say hello! At a minimum, you will need credentials for our Docker Private Registry and a set of Auth0 secrets that will be used in the following steps.

### 1. Create a CNCF compliant cluster

Qualytics fully supports kubernetes clusters hosted in AWS, GCP, and Azure as well as any CNCF-compliant control plane.

#### Node Requirements

Node(s) with the following labels must be made available:
- `appNodes=true`
- `driverNodes=true`
- `executorNodes=true`

Nodes with the `driverNodes=true` and `executorNodes=true` labels will be used for Spark jobs, while nodes with the `appNodes=true` label will be used for all other needs. Users have the flexibility to merge the `driverNodes=true` and `executorNodes=true` labels into a single label, `sparkNodes=true`, within the same node group, as long as the provided node group can supply sufficient resources to handle both Spark driver and executors. Alternatively, users may choose not to use node selectors at all, allowing the entire cluster to be used without targeting specific node groups. However, it is highly recommended to set up autoscaling for Apache Spark operations by providing separate node groups with the `driverNodes=true` and `executorNodes=true` labels to ensure optimal performance and scalability.

|          |          Application Nodes          |               Spark Driver Nodes                |            Spark Executor Nodes            |
|----------|:-----------------------------------:|:-----------------------------------------------:|:------------------------------------------:|
| Label    | appNodes=true                       | driverNodes=true                                | executorNodes=true                         |
| Scaling  | Autoscaling (1 node on-demand)      | Autoscaling (1 node on-demand)                  | Autoscaling (1 - 12 nodes spot)            |
| EKS      | t3.2xlarge (8 vCPUs, 32 GB)         | r5.2xlarge (8 vCPUs, 64 GB)                     | r5d.2xlarge (8 vCPUs, 64 GB)               |
| GKE      | n2-standard-8 (8 vCPUs, 32 GB)      | n2-highmem-8 (8 vCPUs, 64 GB)                   | n2-highmem-8 (8 vCPUs, 64 GB)              |
| AKS      | Standard_D8_v5 (8 vCPUs, 32 GB)     | Standard_E8s_v5 (8 vCPUs, 64 GB)                | Standard_E8s_v5 (8 vCPUs, 64 GB)           |


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

The following command will first ensure that all chart dependencies are available and then proceed with an installation of the Qualytics platform.

```bash
helm repo add qualytics https://qualytics.github.io/qualytics-helm-public
helm upgrade --install qualytics qualytics/qualytics --namespace qualytics --create-namespace -f values.yaml
```

As part of the installation process, an nginx ingress will be configured with an inbound IP address. Make note of this IP address as it is needed for the fourth and final step!

### 4. Register your deployment's web application

Send your [account manager](mailto://hello@qualytics.co) the IP address for your cluster ingress gathered from step 3. Qualytics will assign a DNS record to it under `*.qualytics.io` so that your end users can securely access the deployed web application from a URL such as `https://acme.qualytics.io`

## Can I run a fully "air-gapped" deployment?

Yes. The only egress requirement for a standard self-hosted Qualytics deployment is to https://auth.qualytics.io which provides Auth0-powered federated authentication. This is recommended for ease of installation and support, but not a strict requirement. If you require a fully private deployment with no access to the public internet, you can instead configure an OpenID Connect (OIDC) integration with your enterprise identity provider (IdP). Simply contact your Qualytics account manager for more details.

## Additional Documentation

- [Qualytics UserGuide](https://qualytics.github.io/userguide/)
