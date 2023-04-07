{{- define "generic.labels" -}}
labels:
  app.kubernetes.io/name: {{ include "app.name" $ }}
  app.kubernetes.io/instance: {{ $.Release.Name }}
  app.kubernetes.io/managed-by: {{ $.Release.Service }}
{{- end }}
