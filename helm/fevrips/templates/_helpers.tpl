{{/*
Expand the name of the chart.
*/}}
{{- define "fevrips.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fevrips.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "fevrips.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "fevrips.labels" -}}
helm.sh/chart: {{ include "fevrips.chart" . }}
{{ include "fevrips.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "fevrips.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fevrips.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "fevrips.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "fevrips.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Database connection string template
*/}}
{{- define "fevrips.connectionString" -}}
{{- $dbHost := printf "%s-db" (include "fevrips.fullname" .) }}
{{- $dbPassword := .Values.database.auth.rootPassword }}
{{- if .Values.database.auth.existingSecret }}
{{- $dbPassword = printf "$(SA_PASSWORD)" }}
{{- end }}
Server={{ $dbHost }};Database={{ . }};User Id=sa;Password={{ $dbPassword }};TrustServerCertificate=True;
{{- end }}

{{/*
Database image
*/}}
{{- define "fevrips.database.image" -}}
{{- $registry := .Values.database.image.registry }}
{{- $repository := .Values.database.image.repository }}
{{- $tag := .Values.database.image.tag }}
{{- printf "%s/%s:%s" $registry $repository $tag }}
{{- end }}

{{/*
API image
*/}}
{{- define "fevrips.api.image" -}}
{{- $registry := default .Values.global.imageRegistry .Values.api.image.registry }}
{{- $repository := .Values.api.image.repository }}
{{- $tag := .Values.api.image.tag }}
{{- printf "%s/%s:%s" $registry $repository $tag }}
{{- end }}