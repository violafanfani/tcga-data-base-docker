## base container
FROM mambaorg/micromamba:0.15.3 as base_container
USER root
RUN apt-get update \
    && apt-get install --yes rename tini procps curl \
    && apt-get autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER micromamba
ENTRYPOINT ["tini", "--"]
CMD ["/bin/bash"]

## main container
ARG CONDA_FILE=env.base.python.yml
FROM base_container
# adding opencontainer labels to link registry to github repository
LABEL org.opencontainers.image.title="tcga-data-base-docker"
LABEL org.opencontainers.image.description="Workflow to download and prepare TCGA data"
LABEL org.opencontainers.image.url="https://github.com/violafanfani/tcga-data-base-docker"
LABEL org.opencontainers.image.documentation="https://github.com/violafanfani/tcga-data-base-docker"
LABEL org.opencontainers.image.source="https://github.com/violafanfani/tcga-data-base-docker"
LABEL org.opencontainers.image.vendor="violafanfani"
LABEL org.opencontainers.image.authors="Viola Fanfani"
LABEL org.opencontainers.image.revision="v0.0.3"

COPY --chown=micromamba:micromamba ${CONDA_FILE} /tmp
RUN micromamba install -y -n base -f /tmp/`basename ${CONDA_FILE}` && \
    micromamba clean --all --yes

ARG MAMBA_DOCKERFILE_ACTIVATE=1

#FROM rocker/tidyverse:latest
# Install R packages



# Docker inheritance
FROM bioconductor/bioconductor_docker:devel

# copy install scripts
COPY *.sh /opt 

RUN mkdir -p /opt/install_scripts && \ 
    mv /opt/install*.sh /opt/install_scripts && \
    chmod +x /opt/install_scripts/install*.sh

# install tidyverse
RUN /opt/install_scripts/install_tidyverse.sh

###
RUN apt-get update
## Install cran packages
RUN R -e "install.packages(c('devtools','optparse','ggplot2','cowplot'),\
                            dependencies=TRUE, \
                           repos='http://cran.rstudio.com/')"


## Install our own package

## Install bioconductior packages                           
RUN R -e 'BiocManager::install(ask = F)' && R -e 'BiocManager::install(c("recount3", \
    "edgeR", "GenomicAlignments", "Biostrings", "SummarizedExperiment", "GenomicFiles","recount",\
    "TCGAbiolinks", "GenomicDataCommons","limma","org.Hs.eg.db", ask = F))'






