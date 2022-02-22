UCSB RStudio Base
=================

Base image for launching RStudio via JupyterHub.  This based on the [Jupyter R upstream](https://hub.docker.com/r/jupyter/r-notebook) and adds features and libraries commonly used in data science lab courses at [UCSB](https://ucsb.edu) that make use of [RStudio](https://www.rstudio.com/).  In addition, these builds also include updates to the base OS image as available at the time of build.

## How to run

Generally, refer to [upstream documentation](https://jupyter-docker-stacks.readthedocs.io/en/latest/) for running these containers, however, this container adds an additional /rstudio endpoint with the necessary [jupyter session proxy](https://github.com/jupyterhub/jupyter-rsession-proxy) layer, making it suitable to deploy via [JupyterHub helm chart](https://zero-to-jupyterhub.readthedocs.io/en/latest/) or as a standalone deployment.

## How to build an image from this

In order to build a downstream image, the user should be first set to root, and then reset back once changes are complete:

```
FROM ucsb/rstudio-base:latest

USER root

# Add your changes here
RUN mamba install ...

USER $NB_USER
```

## Tags

`latest` - Periodically a Jupyter release version is tagged in the Containerfile and this tags tracks the most recent build against that particular version.  That version may get updated at least quarterly.

`weekly` - This tag is primarily for integration testing and tracks the upstream `latest` tag.  These images are generally built, tested, and updated weekly on Monday mornings (PDT time).

`v...` - The numbers in these tags represent a date and are effectively a snapshot of the `latest` tag as it was on that particular day.  
