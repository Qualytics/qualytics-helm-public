## What is Qualytics?

Qualytics is a closed source container-native platform for assessing, monitoring, and ameliorating data quality for the Enterprise. Learn more [about our product and capabilities here](https://qualytics.co/product/). 


## K8S Secrets

The following secrets are required in conjunction with this Helm chart.

- Docker Private Registry
```bash
kubectl create secret docker-registry regcred --docker-server=artifactory.qualytics.io:443/docker --docker-username=<your-name> --docker-password=<your-pword>
```

- RabbitMQ
```bash
kubectl create secret generic rabbitmq-creds \
    --from-literal=rabbitmq-password=ChangeMe!
```

- Hub Config
```bash
kubectl create secret generic hub-config \
    --from-literal=connection_url=postgres:postgres@postgres:5432/surveillence_hub \
    --from-literal=secrets_passphrase=ChangeMe! \
    --from-literal=smtp_sender_user=user@smtp.com \
    --from-literal=smtp_sender_password=ChangeMe!
```

- Hub Auth0
``` bash
kubectl create secret generic hub-auth \
    --from-literal=auth0_audience=AUTH0_AUDIENCE \
    --from-literal=auth0_client_id=AUTH0_CLIENT_ID \
    --from-literal=auth0_client_secret=AUTH0_CLIENT_SECRET \
    --from-literal=auth0_organization=AUTH0_ORGANIZATION \
    --from-literal=auth0_spa_client_id=AUTH0_SPA_CLIENT_ID \
    --from-literal=auth0_user_client_id=AUTH0_USER_CLIENT_ID \
    --from-literal=auth0_user_client_secret=AUTH0_USER_CLIENT_SECRET
```

## Documentation

[Qualytics UserGuide](https://qualytics.github.io/userguide/)

## Upcoming Enhancements

- Add K8S cluster requirements like node labels (`appNodes: true` and `sparkNodes: true`) and autoscaling capabilities
