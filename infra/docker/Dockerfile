# Build with the repo root as Docker context:
#   from repo root:    docker build -f infra/docker/Dockerfile -t blt:V3 .
#   from infra/docker: docker build -f Dockerfile -t blt:V3 ../..
FROM rocker/r-ver:4.5.1

ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
ENV CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    build-essential \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libuv1-dev \
    gdal-bin \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libjpeg-dev \
    libtiff5-dev \
    exiftool \
    && rm -rf /var/lib/apt/lists/*

ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
ENV CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

COPY infra/docker/certs/zscaler-intermediate.crt /usr/local/share/ca-certificates/zscaler-intermediate.crt
COPY infra/docker/certs/zscaler-root.crt /usr/local/share/ca-certificates/zscaler-root.crt
RUN update-ca-certificates

RUN curl -Iv https://cloud.r-project.org

RUN R -q -e "options(timeout=300, download.file.method='libcurl', repos=c(CRAN='https://cloud.r-project.org')); install.packages('remotes', Ncpus=1); stopifnot('remotes' %in% rownames(installed.packages()))"

RUN R -q -e "options(timeout=300, download.file.method='libcurl', repos=c(CRAN='https://cloud.r-project.org')); install.packages(c('sass','commonmark','processx'), Ncpus=1, verbose=TRUE)"

RUN R -q -e "options(timeout=300, download.file.method='libcurl', repos=c(CRAN='https://cloud.r-project.org')); install.packages(c('bslib','shiny','pkgload','roxygen2','golem'), Ncpus=1, verbose=TRUE)"

WORKDIR /workspace

COPY . /workspace

RUN R -e "remotes::install_local('/workspace/app', dependencies = TRUE, upgrade = 'never')"

RUN chmod +x /workspace/infra/docker/scripts/docker_entrypoint.sh
RUN mkdir -p /data/project /exports

ENV BLT_HOST=0.0.0.0
ENV BLT_PORT=8090
ENV BLT_LAUNCH_BROWSER=false
ENV GOLEM_CONFIG_ACTIVE=production
ENV R_CONFIG_ACTIVE=production
ENV BLT_PROJECT_DIR=/data/project
ENV BLT_SEED_PROJECT_DIR=/workspace/resources/seed-project
ENV BLT_PROJECT_SETTINGS_TEMPLATE=/workspace/infra/docker/config/container-project-settings.yml
ENV BLT_GENERATED_PROJECT_SETTINGS=/tmp/blt-project-settings.yml
ENV BLT_AUTH_USERS_TEMPLATE=/workspace/infra/docker/config/auth_users.csv
ENV BLT_EXPORT_DIR=/exports
ENV BLT_EXPORT_ROOT_NAME="Export Folder"
ENV BLT_HIDE_IMAGE_EXPORT_BUTTONS=true

EXPOSE 8090

ENTRYPOINT ["/workspace/infra/docker/scripts/docker_entrypoint.sh"]
