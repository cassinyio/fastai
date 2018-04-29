# Copyright (c) 2017, Cassiny.io OÜ
# Distributed under the terms of the Modified BSD License.

# https://hub.docker.com/r/cassinyio/fastai/
FROM cassinyio/base-gpu:3e79acdf

LABEL maintainer "wow@cassiny.io"

USER root

# Update the libraries
RUN apt-get -yq update && \
    apt-get -yq --no-install-recommends upgrade && \
    apt-get -yq --no-install-recommends install \
    libxrender-dev \
    libxext6 \
    libsm6 && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# Jupyter envs
ENV PROBE_IP 0.0.0.0
ENV PROBE_PORT 8888

# Configure environment
ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH
ENV SHELL /bin/bash
ENV NB_USER user
ENV NB_UID 1000
ENV NB_OWNER_GROUP user-writable
ENV NB_OWNER_GID 10000
ENV HOME /home/$NB_USER
ENV MINICONDA_VERSION 3-4.3.31

# Create user with UID=1000 and in the 'user-writable' group
RUN groupadd -g $NB_OWNER_GID $NB_OWNER_GROUP && \
    useradd -m -s /bin/bash -N -u $NB_UID $NB_USER -g $NB_OWNER_GID && \
    mkdir -p $CONDA_DIR && \
    chown $NB_USER $CONDA_DIR

USER $NB_USER

# Install conda as `user`
RUN cd /tmp && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda$MINICONDA_VERSION-Linux-x86_64.sh && \
    /bin/bash Miniconda$MINICONDA_VERSION-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda$MINICONDA_VERSION-Linux-x86_64.sh && \
    $CONDA_DIR/bin/conda config --system --add channels conda-forge && \
    $CONDA_DIR/bin/conda config --system --set auto_update_conda false

# installing libraries
WORKDIR /home/$NB_USER/
COPY requirements.txt $HOME/requirements.txt
RUN git clone https://github.com/fastai/fastai.git
RUN cd fastai && conda env update && conda clean -tipsy
RUN pip install --no-cache-dir -r $HOME/requirements.txt
RUN rm $HOME/requirements.txt

USER root
EXPOSE 8888

# Configure container startup
CMD ["start-notebook.sh"]

# Add local files as late as possible to avoid cache busting
COPY start-notebook.sh /usr/local/bin/start-notebook.sh

# change permissions
RUN chmod +x /usr/local/bin/start-notebook.sh

# Switch back to user
USER $NB_USER
