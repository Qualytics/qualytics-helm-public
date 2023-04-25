## What is Qualytics?

Qualytics is a closed source container-native platform for assessing, monitoring, and ameliorating data quality for the Enterprise. Learn more [about our product and capabilities here](https://qualytics.co/product/).

## What is in this chart?

This chart will deploy a single-tenant instance of the qualytics platform to a [CNCF compliant](https://www.cncf.io/certification/software-conformance/) kubernetes control plane.

![Deployment Architecture](/deployment_arch_diagram.jpg)

## Prerequisites

### Node Requirements

Node(s) with the following labels must be made available:
- appNodes
- sparkNodes


Nodes with the `sparkNodes` label will be used for Spark jobs and nodes with the `appNodes` label will be used for all other needs.  It is possible to provide a single node with both labels if that node provides sufficient resources to operate the entire cluster according to the specified chart values.  However, it is highly recommended to setup autoscaling for Apache Spark operations by providing a group of nodes with the `sparkNodes` label that will grow on demand.

### K8S Secrets

The following secret is required in conjunction with this Helm chart. This secret provides access to Qualytics private registry and the required images that are available there.

- Docker Private Registry
```bash
kubectl create secret docker-registry regcred --docker-server=artifactory.qualytics.io:443/docker --docker-username=<your-name> --docker-password=<your-pword>
```

## Additional Documentation

- [Qualytics UserGuide](https://qualytics.github.io/userguide/)


