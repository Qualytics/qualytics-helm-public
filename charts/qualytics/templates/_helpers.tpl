{{/*
Generate postgres connection URL
*/}}
{{- define "qualytics.postgres.connection_url" -}}
{{- $host := "" -}}
{{- $port := "" -}}
{{- if .Values.postgres.enabled -}}
{{- $host = printf "%s-postgres.%s.svc.cluster.local" .Release.Name .Release.Namespace -}}
{{- $port = toString 5432 -}}
{{- else -}}
{{- $host = .Values.secrets.postgres.host -}}
{{- $port = toString .Values.secrets.postgres.port -}}
{{- end -}}
{{- printf "%s:%s@%s:%s/%s" .Values.secrets.postgres.username .Values.secrets.postgres.password $host $port .Values.secrets.postgres.database -}}
{{- end -}}