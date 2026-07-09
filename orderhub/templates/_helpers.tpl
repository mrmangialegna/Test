{{/*
Expand the name of the chart.
*/}}
{{- define "orderhub.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "orderhub.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Chart name and version label.
*/}}
{{- define "orderhub.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "orderhub.labels" -}}
helm.sh/chart: {{ include "orderhub.chart" . }}
{{ include "orderhub.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "orderhub.selectorLabels" -}}
app.kubernetes.io/name: {{ include "orderhub.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Target namespace for all resources.
*/}}
{{- define "orderhub.namespace" -}}
{{- .Values.namespace.name }}
{{- end }}

{{/*
StorageClass usata dal database.
*/}}
{{- define "orderhub.database.storageClassName" -}}
{{- .Values.database.storageClassName | default .Values.storage.className -}}
{{- end }}
