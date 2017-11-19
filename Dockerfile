# Builds a Docker image with FEniCS and Sfepy for Python3 and Jupyter Notebook
# based on Ubuntu and LXDE desktop environment
#
# Authors:
# Xiangmin Jiao <xmjiao@gmail.com>

# Use PETSc prebuilt in fastsolve/desktop
FROM compdatasci/spyder-desktop:latest
LABEL maintainer "Xiangmin Jiao <xmjiao@gmail.com>"

USER root
WORKDIR /tmp

# Install system packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        git-lfs \
        libnss3 \
        imagemagick \
        \
        libboost-filesystem-dev \
        libboost-iostreams-dev \
        libboost-math-dev \
        libboost-program-options-dev \
        libboost-system-dev \
        libboost-thread-dev \
        libboost-timer-dev \
        libeigen3-dev \
        libomp-dev \
        libpcre3-dev \
        libhdf5-openmpi-dev \
        libgmp-dev \
        libcln-dev \
        libmpfr-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/*

ADD image/home $DOCKER_HOME

# Build FEniCS with Python3
ENV FENICS_BUILD_TYPE=Release \
    FENICS_PREFIX=/usr/local \
    FENICS_VERSION=2017.1.0 \
    FENICS_PYTHON=python3

ARG FENICS_SRC_DIR=/tmp/src

RUN $DOCKER_HOME/bin/fenics-pull && \
    $DOCKER_HOME/bin/fenics-build && \
    ldconfig && \
    rm -rf /tmp/src && \
    rm -f $DOCKER_HOME/bin/fenics-*

# Install fenics-tools (this might be removed later)
RUN cd /tmp && \
    git clone --depth 1 https://github.com/unifem/fenicstools.git && \
    cd fenicstools && \
    python3 setup.py install && \
    rm -rf /tmp/fenicstools

ENV PYTHONPATH=$FENICS_PREFIX/lib/python3/dist-packages:$PYTHONPATH

########################################################
# Customization for user
########################################################

USER $DOCKER_USER
ENV GIT_EDITOR=vi EDITOR=vi
RUN echo 'export OMP_NUM_THREADS=$(nproc)' >> $DOCKER_HOME/.profile && \
    sed -i '/octave/ d' $DOCKER_HOME/.config/lxsession/LXDE/autostart && \
    echo "@spyder" >> $DOCKER_HOME/.config/lxsession/LXDE/autostart && \
    cp -r $FENICS_PREFIX/share/dolfin/demo $DOCKER_HOME/fenics-demo && \
    echo "PATH=$DOCKER_HOME/bin:$PATH" >> $DOCKER_HOME/.profile && \
    echo "alias python=python3" >> $DOCKER_HOME/.profile && \
    echo "alias ipython=ipython3" >> $DOCKER_HOME/.profile

WORKDIR $DOCKER_HOME
USER root
