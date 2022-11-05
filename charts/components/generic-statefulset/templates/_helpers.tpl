{{/* vim: set filetype=mustache: */}}

{{- define "app.name" }}
  {{- required "An app name is required" .Values.app.name | default .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "app.metadata" }}
{{ printf "metadata:" }}
{{ printf "labels: " | indent 2 }}
{{ printf "app: %s" (include "app.name" .) | indent 4 }}
{{ printf "env: %s" (required "A value for env is required" .Values.app.env) | indent 4 }}
{{ printf "name: %s" (include "app.name" .) | indent 2 }}
{{ printf "namespace: %s" (include "app.name" .) | indent 2 }}
{{- end }}

{{- define "app.command" }}
  {{- if .Values.app.config.command }}
    {{ printf "command: [ \"%s\" ]" (join "\",\"" .Values.app.config.command) | indent 4 }}
  {{- end }}
{{- end }}

{{- define "app.envFrom" }}
{{ printf "envFrom:" | indent 10 }}
{{ printf "- configMapRef:" | indent 12 }}
{{ printf "name: %s" (printf "%s-config" (include "app.name" .)) | indent 14 }}
{{- end }}

{{- define "app.header" -}}
{{ printf "apiVersion: apps/v1" }}
{{ printf "kind: StatefulSet" }}
{{- end -}}

{{- define "app.image" }}
  {{ printf "- name: %s" (.Values.app.name) | indent 6 }}
  {{ printf "image: %s:%s" (.Values.app.image) (.Values.app.imageTag) | indent 8 }}
  {{ printf "imagePullPolicy: %s" (.Values.app.imagePullPolicy) | indent 8 }}
{{- end }}

{{- define "app.podAntiAffinity" }}
  {{- if .Values.app.config.podAntiAffinity }}
    {{ printf "affinity:" | indent 2 }}
    {{ printf "podAntiAffinity:" | indent 4 }}
    {{ printf "requiredDuringSchedulingIgnoredDuringExecution:" | indent 6 }}
    {{ printf "- labelSector:" | indent 8 }}
    {{ printf "matchExpression:" | indent 12 }}
    {{ printf "- key: name" | indent 14 }}
    {{ printf "operator: In" | indent 16 }}
    {{ printf "values:" | indent 16 }}
    {{ printf "- %s" (include "app.name" .) | indent 18 }}
    {{ printf "topologyKey: %s" (printf "kubernetes.io/hostname" | quote) | indent 10 }}
  {{- end }}
{{- end }}

{{- define "app.ports" }}
{{ printf "ports:" | indent 10 }}
{{- toYaml .Values.app.networking.ports | nindent 12 }}
{{- end }}

{{- define "app.probes" }}
{{- range $k, $v := .Values.app.probes }}
  {{ printf "%s%s:" $k "Probe" | indent 8 }}
  {{- if eq $v.type "http" }}
    {{ printf "%s:" "httpGet" | indent 8 }}
    {{ printf "%s: %s" "path" ($v.path | quote) | indent 10 }}
    {{ printf "%s: %v" "port" $v.port | indent 10 }}
    {{ printf "%s:" "httpHeaders" | indent 10 }}
    {{ printf "- name: %s" (printf "Host" | quote) | indent 12 }}
    {{ printf "value: %s" (printf $.Values.app.networking.ingress.name | quote) | indent 14 }}
  {{- else if eq $v.type "tcp" }}
    {{ printf "%s:" "tcpSocket" }}
    {{ printf "%s: %v" "port" $v.port | indent 2 }}
  {{- end }}
    {{ printf "%s: %v" "initialDelaySeconds" ($.Values.app.probes.initialDelaySeconds | default 30) | indent 8 }}
    {{ printf "%s: %v" "periodSeconds" ($.Values.app.probes.periodSeconds | default 15) | indent 8 }}
{{- end }}
{{- end }}

{{- define "app.resources" }}
{{ printf "resources:" | indent 10 }}
{{- toYaml .Values.app.resources | nindent 12 }}
{{- end -}}

{{- define "app.volumes" }}
{{- if .Values.app.persistence.nfs.enable }}
  {{ printf "volumes:" | indent 8 }}
  {{ printf "- name: %s" (.Values.app.persistence.nfs.mountName | default (printf "%s-pv" (include "app.name" .))) | indent 10 }}
  {{ printf "nfs:" | indent 12 }}
  {{ printf "path: %s" (required "An NFS mount path is required" .Values.app.persistence.nfs.serverPath | quote) | indent 14 }}
  {{ printf "server: %s" (required "An IP address is required" .Values.app.persistence.nfs.serverIP | quote) | indent 14 }}
{{- end }}
{{- end}}

{{- define "app.volumeMounts" }}
{{- if or .Values.app.persistence.config.enable .Values.app.persistence.nfs.enable }}
  {{ printf "volumeMounts:" | indent 8 }}
{{- end }}
{{- if .Values.app.persistence.config.enable }}
  {{ printf "- mountPath: %s" (.Values.app.persistence.config.mountPath | default "/config") | indent 10 }}
  {{ printf "name: %s" (.Values.app.persistence.config.mountName | default (printf "%s-config" (include "app.name" .))) | indent 12 }}
  {{- if .Values.app.persistence.config.subPath }}
    {{ printf "subPath: %v" .Values.app.persistence.config.subPath | indent 12 }}
  {{- end}}
  {{- if hasKey .Values.app.persistence.config "readOnly" }}
    {{ printf "readOnly: %v" .Values.app.persistence.config.readOnly | indent 20 }}
  {{- end}}
{{- end }}
{{- if .Values.app.persistence.nfs.enable }}
  {{ printf "- mountPath: %s" .Values.app.persistence.nfs.mountPath | indent 10 }}
  {{ printf "name: %s" (.Values.app.persistence.nfs.mountName | default (printf "%s-pv" (include "app.name" .)))| indent 12 }}
  {{ printf "readOnly: %v" (.Values.app.persistence.nfs.readOnly | default true) | indent 12 }}
{{- end }}
{{- end }}

{{- define "app.volumeClaimTemplates" }}
{{- if .Values.app.persistence.config.enable }}
  {{ printf "volumeClaimTemplates:" }}
  {{ printf "- metadata:" | indent 2 }}
  {{ printf "name: %s" (.Values.app.persistence.config.mountName | default (printf "%s-config" (include "app.name" .))) | indent 6 }}
  {{ printf "spec:" | indent 4 }}
  {{ printf "accessModes: [ %s ]" (.Values.app.persistence.config.accessModes | default "ReadWriteOnce" | quote) | indent 6 }}
  {{ printf "storageClassName: %s" (.Values.app.persistence.config.storageClassName | default "longhorn" | quote) | indent 6 }}
  {{ printf "resources:" | indent 6 }}
  {{ printf "requests:" | indent 8 }}
  {{ printf "storage: %s" (.Values.app.persistence.config.size | default "2Gi") | indent 10 }}
{{- end }}
{{- end }}
