## What is Qualytics?

Qualytics is a closed source container-native platform for assessing, monitoring, and ameliorating data quality for the Enterprise. Learn more [about our product and capabilities here](https://qualytics.co/product/). 


## K8S Secrets

The following secret is required in conjunction with this Helm chart.

- Docker Private Registry
```bash
kubectl create secret docker-registry regcred --docker-server=artifactory.qualytics.io:443/docker --docker-username=<your-name> --docker-password=<your-pword>
```

## Documentation

[Qualytics UserGuide](https://qualytics.github.io/userguide/)

## Upcoming Enhancements

- Add K8S cluster requirements like node labels (`appNodes: true` and `sparkNodes: true`) and autoscaling capabilities
