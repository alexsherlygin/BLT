#!/bin/sh
set -eu

config_dir="/etc/alertmanager"
runtime_dir="/alertmanager/runtime"
runtime_config="${runtime_dir}/alertmanager.yml"
secrets_dir="${runtime_dir}/secrets"

mkdir -p "${runtime_dir}" "${secrets_dir}"

has_telegram=0
has_email=0

if [ -n "${TELEGRAM_BOT_TOKEN:-}" ] && [ -n "${TELEGRAM_CHAT_ID:-}" ]; then
  has_telegram=1
  printf '%s' "${TELEGRAM_BOT_TOKEN}" > "${secrets_dir}/telegram_bot_token"
  printf '%s' "${TELEGRAM_CHAT_ID}" > "${secrets_dir}/telegram_chat_id"
elif [ -n "${TELEGRAM_BOT_TOKEN:-}" ] || [ -n "${TELEGRAM_CHAT_ID:-}" ]; then
  echo "telegram alerting is disabled because TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID must both be set" >&2
fi

if [ -n "${ALERT_EMAIL_TO:-}" ] && [ -n "${ALERT_EMAIL_FROM:-}" ] && [ -n "${SMTP_SMARTHOST:-}" ]; then
  if [ -n "${SMTP_AUTH_USERNAME:-}" ] && [ -n "${SMTP_AUTH_PASSWORD:-}" ]; then
    printf '%s' "${SMTP_AUTH_PASSWORD}" > "${secrets_dir}/smtp_auth_password"
    has_email=1
  elif [ -n "${SMTP_AUTH_USERNAME:-}" ] || [ -n "${SMTP_AUTH_PASSWORD:-}" ]; then
    echo "email alerting is disabled because SMTP_AUTH_USERNAME and SMTP_AUTH_PASSWORD must either both be set or both be empty" >&2
  else
    has_email=1
  fi
elif [ -n "${ALERT_EMAIL_TO:-}" ] || [ -n "${ALERT_EMAIL_FROM:-}" ] || [ -n "${SMTP_SMARTHOST:-}" ] || [ -n "${SMTP_AUTH_USERNAME:-}" ] || [ -n "${SMTP_AUTH_PASSWORD:-}" ]; then
  echo "email alerting is disabled because ALERT_EMAIL_TO, ALERT_EMAIL_FROM, and SMTP_SMARTHOST must all be set" >&2
fi

if [ "${has_telegram}" -eq 1 ] || [ "${has_email}" -eq 1 ]; then
  cat > "${runtime_config}" <<EOF
global:
  resolve_timeout: 5m

route:
  receiver: notifications-receiver
  group_by: ["alertname", "job", "instance", "severity"]
  group_wait: 5s
  group_interval: 5m
  repeat_interval: 4h

receivers:
  - name: default-receiver

  - name: notifications-receiver
EOF

  if [ "${has_telegram}" -eq 1 ]; then
    cat >> "${runtime_config}" <<'EOF'
    telegram_configs:
      - bot_token_file: /alertmanager/runtime/secrets/telegram_bot_token
        chat_id_file: /alertmanager/runtime/secrets/telegram_chat_id
        send_resolved: true
        parse_mode: HTML
        http_config:
          proxy_from_environment: true
EOF

    if [ -n "${TELEGRAM_API_URL:-}" ]; then
      cat >> "${runtime_config}" <<EOF
        api_url: ${TELEGRAM_API_URL}
EOF
    fi

    cat >> "${runtime_config}" <<'EOF'
        message: |
          {{ range .Alerts -}}
          <b>{{ .Status | toUpper }}</b> {{ .Labels.alertname }}
          {{- if .Annotations.summary }}
          {{ .Annotations.summary }}
          {{- end }}
          {{- if .Annotations.description }}
          {{ .Annotations.description }}
          {{- end }}
          {{- if .Labels.service }}
          Service: {{ .Labels.service }}
          {{- end }}
          {{- if .Labels.instance }}
          Instance: {{ .Labels.instance }}
          {{- end }}

          {{ end -}}
EOF
  fi

  if [ "${has_email}" -eq 1 ]; then
    cat >> "${runtime_config}" <<EOF
    email_configs:
      - to: ${ALERT_EMAIL_TO}
        from: ${ALERT_EMAIL_FROM}
        smarthost: ${SMTP_SMARTHOST}
        send_resolved: true
        require_tls: ${SMTP_REQUIRE_TLS:-true}
EOF

    if [ -n "${SMTP_HELLO:-}" ]; then
      cat >> "${runtime_config}" <<EOF
        hello: ${SMTP_HELLO}
EOF
    fi

    if [ -n "${SMTP_FORCE_IMPLICIT_TLS:-}" ]; then
      cat >> "${runtime_config}" <<EOF
        force_implicit_tls: ${SMTP_FORCE_IMPLICIT_TLS}
EOF
    fi

    if [ -n "${SMTP_AUTH_USERNAME:-}" ] && [ -n "${SMTP_AUTH_PASSWORD:-}" ]; then
      cat >> "${runtime_config}" <<EOF
        auth_username: ${SMTP_AUTH_USERNAME}
        auth_password_file: /alertmanager/runtime/secrets/smtp_auth_password
EOF
    fi

    cat >> "${runtime_config}" <<'EOF'
        text: |
          {{ range .Alerts -}}
          {{ .Status | toUpper }} {{ .Labels.alertname }}
          {{- if .Annotations.summary }}
          {{ .Annotations.summary }}
          {{- end }}
          {{- if .Annotations.description }}
          {{ .Annotations.description }}
          {{- end }}
          {{- if .Labels.service }}
          Service: {{ .Labels.service }}
          {{- end }}
          {{- if .Labels.instance }}
          Instance: {{ .Labels.instance }}
          {{- end }}

          {{ end -}}
EOF
  fi

  cat >> "${runtime_config}" <<'EOF'

templates: []
EOF
else
  cp "${config_dir}/alertmanager.base.yml" "${runtime_config}"
fi

exec /bin/alertmanager \
  --config.file="${runtime_config}" \
  --storage.path=/alertmanager
