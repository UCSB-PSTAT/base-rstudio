FROM quay.io/jupyter/r-notebook:r-4.5.3

LABEL maintainer="LSIT Systems <lsitops@ucsb.edu>"

USER root

ENV R_STUDIO_VERSION 2026.06.0-242

# System installs and configs
RUN sed -i 's,URIs: http://archive.ubuntu.com/ubuntu/,URIs: https://ftp.ucsb.edu/ubuntu,g;s,Suites: noble noble-updates noble-backports,Suites: noble noble-updates noble-backports noble-security,g' /etc/apt/sources.list.d/ubuntu.sources &&\
    apt update -qq &&\
    apt install software-properties-common -y &&\
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

RUN pip install nbgitpuller && \
    jupyter server extension enable --py nbgitpuller --sys-prefix 

RUN conda install -y -c conda-forge libwebp

RUN conda install -y -c conda-forge --freeze-installed jupyter-server-proxy udunits2 imagemagick pandas numpy r-igraph && \
    conda clean --all

# hack to avoid Rstudio crash introduced in 202605 Rstudio -Kinji Wed Jul  8 04:33:16 PM PDT 2026
RUN pip install git+https://github.com/jupyterhub/jupyter-rsession-proxy@main

# Add the conda lib path for RStudio

RUN pip install matplotlib openai "jupyter-ai[all]<3.0.0"

RUN R -e "install.packages(c('usethis','covr','httr','roxygen2','rversions','imager','patchwork','littler', 'docopt','httr','WDI', 'faraway', 'boot', 'car', 'pscl', 'vcd', 'stargazer', 'effsize', 'Rmisc', 'tidyverse', 'brms', 'rstan', 'pak', 'ottr'), repos = 'https://cloud.r-project.org/', Ncpus = parallel::detectCores())"

RUN R -e "pak::pak('bradleyboehmke/harrypotter')"

RUN R -e "pak::pak('gbm-developers/gbm3')"

RUN /usr/local/bin/fix-permissions "${CONDA_DIR}" || true

RUN chown -R jovyan:users /home/jovyan

USER $NB_USER
