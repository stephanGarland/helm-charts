{{/* vim: set filetype=mustache: */}}

{{- define "app.name" }}
  {{- required "An app name is required" .Values.app.name | default .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "app.command" }}
  {{- if .Values.app.config.command }}
    {{ printf "command: [ \"%s\" ]" (join "\",\"" .Values.app.config.command) | indent 4 }}
  {{- end }}
{{- end }}

{{- define "app.envFrom" }}
  {{- if .Values.app.config.envFrom }}
    {{ printf "envFrom:" | indent 4 }}
    {{ printf "- configMapRef:" | indent 6 }}
    {{ printf "name: %s" (printf "%s-config" (include "app.name" .)) | indent 10 }}
  {{- end}}
{{- end }}

{{- define "app.podAntiAffinity" }}
  {{- if .Values.app.config.podAntiAffinity }}
    {{ printf "affinity:" }}
    {{ printf "podAntiAffinity:" | indent 2 }}
    {{ printf "requiredDuringSchedulingIgnoredDuringExecution:" | indent 4 }}
    {{ printf "- labelSector:" | indent 6 }}
    {{ printf "matchExpression:" | indent 10 }}
    {{ printf "- key: app" | indent 12 }}
    {{ printf "operator: In" | indent 14 }}
    {{ printf "values:" | indent 14 }}
    {{ printf "- %s" (include "app.name" .) | indent 16 }}
    {{ printf "topologyKey: %s" (printf "kubernetes.io/hostname" | quote) | indent 8 }}
  {{- end }}
{{- end }}

{{- define "app.ports" }}
  {{ printf "ports:" | indent 6 }}
  {{- toYaml .Values.app.networking.ports | nindent 10 }}
{{- end }}

{{- define "app.probes" }}
  {{- if .Values.app.config.probes }}
    {{- range $k, $v := .Values.app.probes }}
      {{ printf "%s%s:" $k "Probe" }}
      {{- if eq $v.type "http" }}
        {{ printf "%s:" "httpGet" }}
        {{ printf "%s: %s" "path" ($v.path | quote) | indent 2 }}
        {{ printf "%s: %v" "port" $v.port | indent 2 }}
        {{ printf "%s:" "httpHeaders" | indent 2 }}
        {{ printf "- name: %s" (printf "Host" | quote) | indent 4 }}
        {{ printf "value: %s" (printf $.Values.app.networking.ingress.name | quote) | indent 6 }}
      {{- else if eq $v.type "tcp" }}
        {{ printf "%s:" "tcpSocket" }}
        {{ printf "%s: %v" "port" $v.port | indent 2 }}
      {{- end }}
        {{ printf "%s: %v" "initialDelaySeconds" ($.Values.app.probes.initialDelaySeconds | default 30) | indent 2 }}
        {{ printf "%s: %v" "periodSeconds" ($.Values.app.probes.periodSeconds | default 15) | indent 2 }}
    {{- end }}
  {{- end }}
{{- end }}

{{- define "app.resources" }}
  {{ printf "resources:" | indent 6 }}
  {{- toYaml .Values.app.resources | nindent 10 }}
{{- end }}

{{- define "app.volumes" }}
  {{- if .Values.app.persistence.nfs.enable }}
    {{ printf "volumes:" | indent 2 }}
    {{ printf "- name: %s" (.Values.app.persistence.nfs.mountName | default (printf "%s-pv" (include "app.name" .))) | indent 4 }}
    {{ printf "nfs:" | indent 6 }}
    {{ printf "path: %s" (required "An NFS mount path is required" .Values.app.persistence.nfs.serverPath | quote) | indent 8 }}
    {{ printf "server: %s" (required "An IP address is required" .Values.app.persistence.nfs.serverIP | quote) | indent 8 }}
  {{- end }}
{{- end}}

{{- define "app.volumeMounts" }}
  {{- if or .Values.app.persistence.config.enable .Values.app.persistence.nfs.enable }}
    {{ printf "volumeMounts:" | indent 4 }}
  {{- end }}
  {{- if .Values.app.persistence.config.enable }}
    {{ printf "- mountPath: %s" (.Values.app.persistence.config.mountPath | default "/config") | indent 6 }}
    {{ printf "name: %s" (.Values.app.persistence.config.mountName | default (printf "%s-config" (include "app.name" .))) | indent 8 }}
    {{- if .Values.app.persistence.config.subPath }}
      {{ printf "subPath: %v" .Values.app.persistence.config.subPath | indent 6 }}
    {{- end}}
    {{- if hasKey .Values.app.persistence.config "readOnly" }}
      {{ printf "readOnly: %v" .Values.app.persistence.config.readOnly | indent 6 }}
    {{- end}}
  {{- end }}
  {{- if .Values.app.persistence.nfs.enable }}
    {{ printf "- mountPath: %s" .Values.app.persistence.nfs.mountPath | indent 6 }}
    {{ printf "name: %s" (.Values.app.persistence.nfs.mountName | default (printf "%s-pv" (include "app.name" .)))| indent 8 }}
    {{ printf "readOnly: %v" (.Values.app.persistence.nfs.readOnly | default true) | indent 8 }}
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