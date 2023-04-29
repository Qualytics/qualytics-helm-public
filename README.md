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
- appNodes
- sparkNodes


Nodes with the `sparkNodes` label will be used for Spark jobs and nodes with the `appNodes` label will be used for all other needs.  It is possible to provide a single node with both labels if that node provides sufficient resources to operate the entire cluster according to the specified chart values.  However, it is highly recommended to setup autoscaling for Apache Spark operations by providing a group of nodes with the `sparkNodes` label that will grow on demand.

#### Docker Registry Secrets

Execute the command below using the credentials supplied by your account manager as replacements for "your-name" and "your-pword". The secret created will provide access to Qualytics private registry and the required images that are available there.

- Docker Private Registry
```bash
kubectl create secret docker-registry regcred --docker-server=artifactory.qualytics.io:443/docker --docker-username=<your-name> --docker-password=<your-pword>
```

### 2. Update values.yaml with appropriate values

Update `values.yaml` according to your requirements. At minimum, the "secrets" section at the top should be updated with the Auth0 settings supplied by your Qualytics account manager.

```
auth0_audience: changeme-api
auth0_organization: org_changeme
auth0_spa_client_id: spa_client_id
auth0_client_id: m2m_client_id
auth0_client_secret: m2m_client_secret
auth0_user_client_id: m2m_user_client_id
auth0_user_client_secret: m2m_user_client_secret
```

Contact your [Qualytics account manager](mailto://hello@qualytics.co) for assistance.

### 3. Deploy Qualytics to your cluster

The following command will first ensure that all chart dependencies are availble and then proceed with an installation of the Qualytics platform.

`helm dependency build; helm install qualytics ./`

As part of the install process, an nginx ingress will be configured with an inbound IP address. Make note of this IP address as it is needed for the fourth and final step!

### 4. Register your deployment's web application

Send your [account manager](mailto://hello@qualytics.co) the IP address for your cluster ingress gathered from step 3. Qualytics will assign a DNS record to it under `*.qualytics.io` so that your end users can securely access the deployed web application from a URL such as `https://acme.qualytics.io`

## Additional Documentation

- [Qualytics UserGuide](https://qualytics.github.io/userguide/)


