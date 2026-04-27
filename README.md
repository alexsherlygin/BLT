# BLT

Repository layout:

- `app/` contains the R package and Shiny/golem application source.
- `infra/docker/` contains the Dockerfile, entrypoint, runtime launcher, and certificates.
- `resources/seed-project/` contains the seeded lookup files and sample project assets used by Docker.
- `docs/` contains repo-level notes such as local setup and release notes.

Useful commands from the repo root:

```bash
Rscript app/dev/run_dev.R
```

```bash
Rscript -e 'install.packages("remotes"); remotes::install_local("app", dependencies = TRUE)'
```

```bash
docker build -f infra/docker/Dockerfile .
```

```bash
docker compose up --build
```

The Compose setup includes a container health check and an `autoheal` sidecar so BLT can be restarted automatically if the app stops answering HTTP requests or stops updating its internal heartbeat.
It also includes a basic monitoring and alerting stack with `Prometheus`, `Alertmanager`, `blackbox_exporter`, and `node_exporter`, with Prometheus exposed on port `9090` and Alertmanager on port `9093` by default.
Container lifecycle monitoring is prepared through `cAdvisor`, exposed on port `8081` by default, for BLT container start and restart alert rules.
Telegram delivery can be enabled by setting `TELEGRAM_BOT_TOKEN` and `TELEGRAM_CHAT_ID` in a local `.env` file before recreating `alertmanager`.
Alertmanager includes the bundled Zscaler CA certificates in its trust path by default via `ALERTMANAGER_SSL_CERT_DIR`, so Telegram notifications can work behind corporate TLS inspection.
If outbound traffic must use a corporate proxy, set `ALERTMANAGER_HTTP_PROXY`, `ALERTMANAGER_HTTPS_PROXY`, and `ALERTMANAGER_NO_PROXY` in `.env`; Alertmanager's Telegram client is configured to honor those values.
Email delivery can also be enabled from the local `.env` by setting `ALERT_EMAIL_TO`, `ALERT_EMAIL_FROM`, and `SMTP_SMARTHOST`, with optional SMTP auth variables when the mail server requires authentication.

Package-specific README and installation details are in [`app/README.md`](app/README.md).
