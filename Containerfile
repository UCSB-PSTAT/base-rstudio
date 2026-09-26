FROM quay.io/jupyter/r-notebook:r-4.5.3

LABEL maintainer="LSIT Systems <lsitops@ucsb.edu>"

USER root

ENV R_STUDIO_VERSION 2026.06.0-242

# System installs and configs
RUN sed -i 's,URIs: http://archive.ubuntu.com/ubuntu/,URIs: https://ftp.ucsb.edu/ubuntu,g;s,Suites: noble noble-updates noble-backports,Suites: noble noble-updates noble-backports noble-security,g' /etc/apt/sources.list.d/ubuntu.sources &&\
    apt update -qq &&\
    apt upgrade -y &&\
    apt install -y \
    build-essential\
    cmake\
    curl\
    gfortran\
    git\
    git-lfs\
    jq\
    less\
    libapparmor1\
    libboost-all-dev\
    libcairo2-dev\
    libclang-dev\
    libcurl4-openssl-dev\
    libfftw3-dev\
    libglpk-dev\
    libnlopt-dev\
    libpq-dev\
    libssh2-1-dev\
    libssl-dev\
    libtiff5-dev\
    libuser\
    libuser1-dev\
    libv8-dev\
    libx11-dev\
    libxml2-dev\
    lmodern\
    lsof\
    psmisc\
    rrdtool\
    software-properties-common\
    wget\
    x11-utils &&\
    ## Install/Config RStudio from source package
    wget https://download1.rstudio.org/electron/jammy/amd64/rstudio-${R_STUDIO_VERSION}-amd64.deb &&\
    wget https://download2.rstudio.org/server/jammy/amd64/rstudio-server-${R_STUDIO_VERSION}-amd64.deb &&\
    apt install ./rstudio*.deb -yq &&\
    rm -f ./rstudio*.deb &&\
    chmod 777 /var/run/rstudio-server &&\
    chmod +t /var/run/rstudio-server &&\
    echo "rsession-ld-library-path=/opt/conda/lib" >> /etc/rstudio/rserver.conf &&\
    apt-get clean &&\
    ## Configure git lfs and R for all system users
    git config --system filter.lfs.clean "git-lfs clean -- %filter-replica" && \
    git config --system filter.lfs.smudge "git-lfs smudge -- %filter-replica" && \
    git config --system filter.lfs.process "git-lfs filter-process" &&\
    Rscript -e "dotR <- file.path(Sys.getenv('HOME'), '.R'); if(!file.exists(dotR)){ dir.create(dotR) }; Makevars <- file.path(dotR, 'Makevars'); if (!file.exists(Makevars)){  file.create(Makevars) }; cat('\nCXX14FLAGS=-O3 -fPIC -Wno-unused-variable -Wno-unused-function', 'CXX14 = g++ -std=c++1y -fPIC', 'CXX = g++', 'CXX11 = g++', 'CC = gcc','FC = /usr/bin/gfortran', file = Makevars, sep = '\n', append = TRUE)"

# Consolidate Conda Installations (Python + R Packages plus any of their configs)
RUN mamba install -y -c conda-forge --freeze-installed \
    imagemagick\
    "jupyter-ai=2.*"\
    jupyter-rsession-proxy\
    jupyter-server-proxy\
    libwebp\
    matplotlib\
    nbgitpuller\
    numpy\
    openai\
    pandas\
    udunits2\
    r-pak &&\
    conda clean -afy &&\
    jupyter server extension enable --py nbgitpuller --sys-prefix &&\
    chown -R $NB_USER:$NB_GID /home/jovyan &&\
    /usr/local/bin/fix-permissions "${CONDA_DIR}" || true

# Rscript Installs and Configs
RUN Rscript -e "install.packages(c('usethis','covr','httr','roxygen2','rversions','imager','patchwork','littler', 'docopt','httr','WDI', 'faraway', 'boot', 'car', 'pscl', 'vcd', 'stargazer', 'effsize', 'Rmisc', 'tidyverse', 'brms', 'rstan', 'ottr'), repos = 'https://cloud.r-project.org/', Ncpus = parallel::detectCores())" &&\
    Rscript -e "pak::pak(c('bradleyboehmke/harrypotter', 'gbm-developers/gbm3'))" &&\
    Rscript -e "pak::cache_clean()" &&\
    rm -rf ~/.cache/R /root/.cache/R /tmp/Rtmp* &&\
    chown -R $NB_USER:$NB_GID /home/jovyan &&\
    /usr/local/bin/fix-permissions "${CONDA_DIR}" || true

USER $NB_USER
