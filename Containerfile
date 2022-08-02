FROM jupyter/r-notebook:r-4.1.3

LABEL maintainer="LSIT Systems <lsitops@ucsb.edu>"

USER root

ENV R_STUDIO_VERSION 2022.02.3-492

RUN apt update -qq && \
    apt upgrade -y && \
    apt install -y \
        software-properties-common \
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
        libv8-dev \
        libssh2-1-dev \
## install git command line
        git \
        git-lfs \
## install RStudio Server session components
        curl \
        libuser \
        libuser1-dev \
        libpq-dev \
        rrdtool \  
## install rstan build reqs
        build-essential \
        libxml2-dev \
        libcurl4-openssl-dev \
        libssl-dev \
        build-essential \
        cmake \
        libnlopt-dev \
        libboost-all-dev \
    wget && \
    wget https://download1.rstudio.org/desktop/bionic/amd64/rstudio-${R_STUDIO_VERSION}-amd64.deb && \
    wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-${R_STUDIO_VERSION}-amd64.deb && \
    apt install ./rstudio*.deb -yq && apt-get clean && rm -f ./rstudio*.deb && \
    apt-get clean 

RUN chmod 777 /var/run/rstudio-server && chmod +t /var/run/rstudio-server

RUN R -e "dotR <- file.path(Sys.getenv('HOME'), '.R'); if(!file.exists(dotR)){ dir.create(dotR) }; Makevars <- file.path(dotR, 'Makevars'); if (!file.exists(Makevars)){  file.create(Makevars) }; cat('\nCXX14FLAGS=-O3 -fPIC -Wno-unused-variable -Wno-unused-function', 'CXX14 = g++ -std=c++1y -fPIC', 'CXX = g++', 'CXX11 = g++', file = Makevars, sep = '\n', append = TRUE)"

RUN pip install nbgitpuller && \
    jupyter serverextension enable --py nbgitpuller --sys-prefix 
    
RUN mamba install -y -c conda-forge --freeze-installed jupyter-server-proxy jupyter-rsession-proxy udunits2 imagemagick r-rstan pandas numpy matplotlib

RUN R -e "install.packages(c('usethis','covr','httr','roxygen2','rversions','igraph','imager','patchwork','littler', 'docopt','httr','WDI', 'faraway', 'boot', 'car', 'pscl', 'vcd', 'stargazer', 'effsize', 'Rmisc', 'tidyverse', 'brms', 'rstan'), repos = 'https://cloud.r-project.org/', Ncpus = parallel::detectCores())"

RUN R -e "devtools::install_github('bradleyboehmke/harrypotter')"

RUN R -e "devtools::install_github('gbm-developers/gbm3')"

RUN R -e "devtools::install_github('ucbds-infra/ottr@0.0.2')"

USER $NB_USER

RUN git lfs install
