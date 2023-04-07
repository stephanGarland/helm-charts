{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "app.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Pods Labels
*/}}
{{- define "pods.labels" -}}
{{- if .Values.pods.labels -}}
{{- .Values.pods.labels | toYaml -}}
{{- end -}}
{{- end -}}

{{/*
Pods template Labels
*/}}
{{- define "pods.podLabels" -}}
{{- if .Values.pods.podLabels -}}
{{- .Values.pods.podLabels | toYaml -}}
{{- end -}}
{{- end -}}

{{/*
Pods Env variables
*/}}
{{- define "pods.env" -}}
{{- if .Values.pods.env -}}
{{- .Values.pods.env | toYaml -}}
{{- end -}}
{{- end -}}
