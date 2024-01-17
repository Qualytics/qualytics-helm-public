{{/*
Generate postgres connection URL
*/}}
{{- define "qualytics.postgres.connection_url" -}}
{{- $host := "" -}}
{{- if .Values.postgres.enabled -}}
{{- $host = printf "%s-postgres.%s.svc.cluster.local" .Release.Name .Release.Namespace -}}
{{- else -}}
{{- $host = .Values.secrets.postgres.host -}}
{{- end -}}
{{- $port := toString .Values.secrets.postgres.port -}}
{{- printf "%s:%s@%s:%s/%s" .Values.secrets.postgres.username .Values.secrets.postgres.password $host $port .Values.secrets.postgres.database -}}
{{- end -}}