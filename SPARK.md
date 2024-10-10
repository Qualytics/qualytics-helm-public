# SparkApplication Configuration Guide Without Webhook

## Overview

In certain environments, particularly restricted on-prem setups, it may be necessary to disable the Kubernetes Spark Operator webhook. When the webhook is disabled, environment variables (env vars) cannot be injected into the Spark driver or executors, which requires using Java properties (`-D` properties) to configure the SparkApplication.

This guide explains how to modify your `SparkApplication` spec to work without the webhook and outlines key changes necessary for environments with strict limitations.

## Why Disable the Webhook?

The Spark Operator webhook provides several features that help customize Spark driver and executor pods, such as injecting environment variables, node selectors, tolerations, and volumes. However, in some restricted environments, enabling the webhook might not be possible due to security policies or network limitations.

## Key Differences Without the Webhook

### 1. No Environment Variable Injection

With the webhook disabled, environment variables cannot be injected into the Spark driver or executor pods. Instead, configurations that would normally be set via environment variables must be passed as Java properties using the `javaOptions` field.

For example:

```yaml
javaOptions:
  "-Dmother.rabbit_mq_host={{ .Release.Name }}-rabbitmq
   -Dmother.rabbit_mq_user=user
   -Dmother.rabbit_mq_pass={{ .Values.secrets.rabbitmq.rabbitmq_password }}
   -Dmother.use_cache={{ .Values.firewall.useCache }}
   -Dmother.max_executors={{ .Values.firewall.maxExecutors }}
   -Dmother.num_cores_per_executor={{ .Values.firewall.numCoresPerExecutor }}
   -Dmother.max_memory_per_executor={{ .Values.firewall.maxMemoryPerExecutor }}
   -Dmother.libpostal_data_path={{ .Values.firewall.libpostalDataPath }}
   -Dkubernetes.master=https://kubernetes.default.svc
   -Dkubernetes.namespace=default
   -Dkubernetes.serviceaccount.name=spark-driver
   -Dkubernetes.auth.mountPath=/var/run/secrets/kubernetes.io/serviceaccount
   -Dkubernetes.trust.certificates=true
```

### 2. No Node Selectors, Tolerations, or Volumes

With the webhook disabled, features such as node selectors, tolerations, and volumes cannot be applied. This means Spark workloads will run on the default node pool, and local SSDs or other volume mounts are not configurable.

### 3. Java Properties Instead of Env Vars

All configurations that were previously passed using env vars (e.g., `MOTHERSHIP_RABBIT_HOST`) need to be passed as Java properties in the `javaOptions` field.

For example:
```yaml
-Dmother.rabbit_mq_host={{ .Release.Name }}-rabbitmq
-Dmother.rabbit_mq_user=user
-Dmother.rabbit_mq_pass={{ .Values.secrets.rabbitmq.rabbitmq_password }}
```

### 4. Removed Node Selectors, Tolerations, and Volumes

Since node selectors, tolerations, and volumes are not available without the webhook, they must be removed from the spec.

```yaml
# Example of removing node selectors, tolerations, and volumes:
# driver:
#   nodeSelector: 
#     disktype: ssd
#   tolerations:
#     - key: "dedicated"
#       operator: "Equal"
#       value: "spark"
#       effect: "NoSchedule"
#   volumes:
#     - name: spark-local-dir
#       hostPath:
#         path: "/mnt/spark"
# executor:
#   volumeMounts:
#     - name: spark-local-dir
#       mountPath: "/tmp/spark"
```

## Example SparkApplication Spec

Here’s an example of a `SparkApplication` spec with the necessary adjustments when the webhook is disabled:

```yaml
apiVersion: "sparkoperator.k8s.io/v1beta2"
kind: SparkApplication
metadata:
  name: {{ .Release.Name }}-spark
spec:
  type: Scala
  mode: cluster
  image: "{{ tpl .Values.global.imageUrls.firewallImageUrl . }}:{{ .Values.firewallImage.image.firewallImageTag }}"
  imagePullPolicy: IfNotPresent
  imagePullSecrets:
    - regcred
  restartPolicy:
    type: Always
    onFailureRetries: 1000
    onFailureRetryInterval: 5
    onSubmissionFailureRetries: 1000
    onSubmissionFailureRetryInterval: 5
  mainClass: io.qualytics.firewall.SparkMothership
  mainApplicationFile: "local:///opt/spark/jars/firewall-core.jar"
  sparkVersion: {{ .Values.firewall.sparkVersion }}
  sparkConf:
    spark.eventLog.enabled: {{ .Values.firewall.eventLog | quote }}
    spark.kubernetes.memoryOverheadFactor: {{ .Values.firewall.memoryOverheadFactor | quote }}
    spark.kubernetes.submission.connectionTimeout: "480000"
    spark.kubernetes.submission.requestTimeout: "480000"
    spark.kubernetes.driver.connectionTimeout: "480000"
    spark.kubernetes.driver.requestTimeout: "480000"
  driver:
{{- $resources := .Values.firewall -}}
    {{- with $resources.driver }}
    cores: {{ .cores }}
    coreLimit: {{ .coreLimit }}
    memory: {{ .memory }}
    {{- end }}
    javaOptions:
      "-Divy.cache.dir=/tmp
       -Divy.home=/tmp
       -Dlog4j.configuration=file:/opt/spark/log4j.properties
       -Dconfig.resource=prod.conf
       -Djava.library.path=/opt/spark/libs/
       -Duser.timezone=UTC
       -Dmother.rabbit_mq_host={{ .Release.Name }}-rabbitmq
       -Dmother.rabbit_mq_user=user
       -Dmother.rabbit_mq_pass={{ .Values.secrets.rabbitmq.rabbitmq_password }}
       -Dmother.use_cache={{ .Values.firewall.useCache }}
       -Dmother.max_executors={{ .Values.firewall.maxExecutors }}
       -Dmother.num_cores_per_executor={{ .Values.firewall.numCoresPerExecutor }}
       -Dmother.max_memory_per_executor={{ .Values.firewall.maxMemoryPerExecutor }}
       -Dmother.libpostal_data_path={{ .Values.firewall.libpostalDataPath }}              
       -Dkubernetes.serviceaccount.name={{ .Values.sparkoperator.spark.serviceAccount.name }}
       -Dkubernetes.namespace=default
       -Dkubernetes.master=https://kubernetes.default.svc
       -Dkubernetes.auth.mountPath=/var/run/secrets/kubernetes.io/serviceaccount
       -Dkubernetes.trust.certificates=true
       -XX:+UseG1GC -XX:G1HeapRegionSize=32M -XX:InitiatingHeapOccupancyPercent=35"
    labels:
      version: {{ .Values.firewall.sparkVersion }}
    serviceAccount: {{ .Values.sparkoperator.spark.serviceAccount.name }}
  dynamicAllocation:
    {{- with $resources.dynamicAllocation }}
    enabled: true
    initialExecutors: {{ .initialExecutors }}
    minExecutors: {{ .minExecutors }}
    maxExecutors: {{ .maxExecutors }}
    {{- end }}
  executor:
    {{- with $resources.executor }}
    instances: {{ .instances }}
    cores: {{ .cores }}
    coreLimit: {{ .coreLimit }}
    memory: {{ .memory }}
    {{- end }}
    javaOptions:
      "-Dlog4j.configuration=file:/opt/spark/log4j.properties 
       -Djava.library.path=/opt/spark/libs/
       -Duser.timezone=UTC
       -XX:+UseG1GC -XX:G1HeapRegionSize=32M -XX:InitiatingHeapOccupancyPercent=35"
    labels:
      version: {{ .Values.firewall.sparkVersion }}
```

## Conclusion

When running Spark in restricted environments where the webhook of the Kubernetes Spark Operator is disabled, it is necessary to adapt the configuration as shown above. By using Java properties in `javaOptions` and removing certain features like node selectors and volume mounts, you can ensure compatibility in these environments.
