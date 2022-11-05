{{- define "app.replicas" -}}
{{ if eq .Values.app.kind "Deployment" }}
  {{ printf "replicas: %v\n" .Values.app.config.replicas | default 1 }}
{{- end }}
{{- end }}