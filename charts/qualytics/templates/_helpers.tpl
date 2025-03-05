{{/*
Generate postgres connection URL
*/}}
{{- define "qualytics.postgres.connection_url" -}}
{{- $host := printf "%s-postgres.%s.svc.cluster.local" .Release.Name .Release.Namespace -}}
{{- $port := toString 5432 -}}
{{- $sslMode := "prefer" -}}
{{- if and .Values.certmanager.enabled .Values.postgres.tls.enabled -}}
{{- $sslMode = "require" -}}
{{- end -}}
{{- printf "%s:%s@%s:%s/%s?sslmode=%s" .Values.postgres.username .Values.postgres.password $host $port .Values.postgres.database $sslMode -}}
{{- end -}}