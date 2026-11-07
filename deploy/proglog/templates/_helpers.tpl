{{/*
The name is fixed (not derived from the release) because the server
certificate's SANs are issued for *.proglog.<namespace>.svc.cluster.local.
*/}}
{{- define "proglog.fullname" -}}
{{- default .Chart.Name .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "proglog.serviceDomain" -}}
{{ include "proglog.fullname" . }}.{{ .Release.Namespace }}.svc.cluster.local
{{- end }}

{{- define "proglog.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "proglog.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{ include "proglog.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "proglog.probe" -}}
exec:
  command:
    - /bin/grpc_health_probe
    - -addr=localhost:{{ .Values.rpcPort }}
    - -tls
    - -tls-ca-cert=/etc/proglog/tls/ca.pem
    - -tls-client-cert=/etc/proglog/tls/root-client.pem
    - -tls-client-key=/etc/proglog/tls/root-client-key.pem
    - -tls-server-name=localhost
{{- end }}
