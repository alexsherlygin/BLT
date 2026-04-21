FROM rocker/r-ver:4.5.1

RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    gdal-bin \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libjpeg-dev \
    libtiff5-dev \
    exiftool \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN R -e "install.packages(c('remotes', 'shiny', 'golem', 'roxygen2', 'pkgload'), repos='https://cloud.r-project.org')"

WORKDIR /app

COPY . /app

RUN R -e "remotes::install_local('/app', dependencies = TRUE, upgrade = 'never')"
RUN chmod +x /app/scripts/docker_entrypoint.sh
RUN mkdir -p /data/project /exports

ENV PANNOTATOR_HOST=0.0.0.0
ENV PANNOTATOR_PORT=8090
ENV PANNOTATOR_LAUNCH_BROWSER=false
ENV GOLEM_CONFIG_ACTIVE=production
ENV R_CONFIG_ACTIVE=production
ENV PANNOTATOR_PROJECT_DIR=/data/project
ENV PANNOTATOR_SEED_PROJECT_DIR=/app/Extra
ENV PANNOTATOR_PROJECT_SETTINGS_TEMPLATE=/app/container-project-settings.yml
ENV PANNOTATOR_GENERATED_PROJECT_SETTINGS=/tmp/pannotator-project-settings.yml
ENV PANNOTATOR_EXPORT_DIR=/exports
ENV PANNOTATOR_EXPORT_ROOT_NAME="Export Folder"

EXPOSE 8090

ENTRYPOINT ["/app/scripts/docker_entrypoint.sh"]
