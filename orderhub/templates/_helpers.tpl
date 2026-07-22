{{/*
Expand the name of the chart.
*/}}
{{- define "orderhub.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "orderhub.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
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
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "orderhub.selectorLabels" -}}
app.kubernetes.io/name: {{ include "orderhub.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
