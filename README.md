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

Package-specific README and installation details are in [`app/README.md`](app/README.md).
