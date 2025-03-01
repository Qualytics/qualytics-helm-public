{{/*
Generate postgres connection URL
*/}}
{{- define "qualytics.postgres.connection_url" -}}
{{- $host := "" -}}
{{- $port := "" -}}
{{- $sslmode := "" -}}
{{- if .Values.postgres.enabled -}}
{{- $host = printf "%s-postgres.%s.svc.cluster.local" .Release.Name .Release.Namespace -}}
{{- $port = toString 5432 -}}
{{- if and .Values.postgres.tls.enabled .Values.certmanager.enabled -}}
{{- $sslmode = "?sslmode=require" -}}
{{- else -}}
{{- $sslmode = "?sslmode=prefer" -}}
{{- end -}}
{{- else -}}
{{- $host = .Values.secrets.postgres.host -}}
{{- $port = toString .Values.secrets.postgres.port -}}
{{- $sslmode = "?sslmode=prefer" -}}
{{- end -}}
{{- printf "%s:%s@%s:%s/%s%s" .Values.secrets.postgres.username .Values.secrets.postgres.password $host $port .Values.secrets.postgres.database $sslmode -}}
{{- end -}}

{{/*
Extract CA Certificate from cert-manager issuer for TLS
*/}}
{{- define "qualytics.cacert" -}}
{{- if .Values.certmanager.enabled -}}
{{- $caSecretName := "letsencrypt-ca" -}}
{{- end -}}
{{- end -}}