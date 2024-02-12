FROM jupyter/r-notebook:r-4.3.1

LABEL maintainer="LSIT Systems <lsitops@ucsb.edu>"

USER root

ENV R_STUDIO_VERSION 2023.06.1-524

RUN apt update -qq && \
    apt install software-properties-common -y && \
    add-apt-repository ppa:nrbrtx/libssl1 && \
    apt update -qq && \
    apt upgrade -y && \
    apt install -y \
        jq \
        lsof \
        less \
        libapparmor1 \
        libtiff5-dev \
        libfftw3-dev \
        libcairo2-dev \
        libx11-dev \
        x11-utils \
        psmisc \
        libclang-dev \
        gfortran \
        libglpk-dev \
        libxml2-dev \
        libv8-dev \
        libssh2-1-dev \
        git \
        git-lfs \
        curl \
        libuser \
        libuser1-dev \
        libpq-dev \
        rrdtool \  
        build-essential \
        libxml2-dev \
        libcurl4-openssl-dev \
        libssl-dev \
        build-essential \
        cmake \
        libnlopt-dev \
        libboost-all-dev \
        wget \
        lmodern && \
        apt-get clean

## Install rstudio from source package
RUN wget https://download1.rstudio.org/electron/jammy/amd64/rstudio-${R_STUDIO_VERSION}-amd64.deb && \
    wget https://download2.rstudio.org/server/jammy/amd64/rstudio-server-${R_STUDIO_VERSION}-amd64.deb && \
    apt install ./rstudio*.deb -yq && apt-get clean && rm -f ./rstudio*.deb && \
    apt-get clean 

RUN chmod 777 /var/run/rstudio-server && chmod +t /var/run/rstudio-server

RUN R -e "dotR <- file.path(Sys.getenv('HOME'), '.R'); if(!file.exists(dotR)){ dir.create(dotR) }; Makevars <- file.path(dotR, 'Makevars'); if (!file.exists(Makevars)){  file.create(Makevars) }; cat('\nCXX14FLAGS=-O3 -fPIC -Wno-unused-variable -Wno-unused-function', 'CXX14 = g++ -std=c++1y -fPIC', 'CXX = g++', 'CXX11 = g++', 'CC = gcc','FC = /usr/bin/gfortran', file = Makevars, sep = '\n', append = TRUE)"

RUN pip install nbgitpuller && \
    jupyter server extension enable --py nbgitpuller --sys-prefix 

RUN mamba install -y -c conda-forge libwebp

RUN mamba install -y -c conda-forge --freeze-installed jupyter-server-proxy jupyter-rsession-proxy udunits2 imagemagick pandas numpy r-igraph && \
    mamba clean --all

RUN pip install matplotlib

RUN R -e "install.packages(c('usethis','covr','httr','roxygen2','rversions','imager','patchwork','littler', 'docopt','httr','WDI', 'faraway', 'boot', 'car', 'pscl', 'vcd', 'stargazer', 'effsize', 'Rmisc', 'tidyverse', 'brms', 'rstan'), repos = 'https://cloud.r-project.org/', Ncpus = parallel::detectCores())"

RUN R -e "devtools::install_github('bradleyboehmke/harrypotter')"

RUN R -e "devtools::install_github('gbm-developers/gbm3')"

RUN R -e "devtools::install_github('ucbds-infra/ottr@stable')"

RUN /usr/local/bin/fix-permissions "${CONDA_DIR}" || true

RUN /usr/local/bin/fix-permissions "${CONDA_DIR}" || true

USER $NB_USER

RUN git lfs install
