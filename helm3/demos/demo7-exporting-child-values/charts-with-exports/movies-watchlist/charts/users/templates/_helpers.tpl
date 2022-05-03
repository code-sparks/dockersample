{{- define "users.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "users.database" -}}
{{- if .Values.databaseOverride -}}
{{- .Values.databaseOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name .Values.data.databaseChart | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

