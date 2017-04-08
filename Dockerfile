# Builds a Docker image for FEniCS in a Desktop environment
# with Ubuntu, LXDE, and Python 3.
#
# The built image can be found at:
#   https://hub.docker.com/r/unifem/fenics-desktop
#
# Authors:
# Xiangmin Jiao <xmjiao@gmail.com>

FROM unifem/fenics-jupyter
LABEL maintainer "Xiangmin Jiao <xmjiao@gmail.com>"

USER root
WORKDIR /tmp

ENV DEBIAN_FRONTEND noninteractive

# Install some required system tools and packages for X Windows
# We install firefox and make --no-remote to be default
# Install FreeCAD and Gmsh
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    add-apt-repository ppa:freecad-maintainers/freecad-stable && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-server \
        net-tools \
        python-pip \
        python-dev \
        spyder3 \
        g++ \
        \
        xserver-xorg-video-dummy \
        lxde \
        x11-xserver-utils \
        gnome-themes-standard \
        gtk2-engines-pixbuf \
        gtk2-engines-murrine \
        ttf-ubuntu-font-family \
        xfonts-base xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic \
        mesa-utils \
        libgl1-mesa-dri \
        x11vnc \
        \
        meld \
        emacs24 \
        firefox \
	xpdf \
	\
	freecad \
        gmsh \
        paraview && \
    sed -i 's/MOZ_APP_NAME "\$@"/MOZ_APP_NAME --no-remote "\$@"/' /usr/bin/firefox && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip2 install -U pip \
        setuptools && \
	\
    pip2 install -U https://github.com/novnc/websockify/archive/master.tar.gz && \
    mkdir /usr/local/noVNC && \
    curl -s -L https://github.com/novnc/noVNC/archive/stable/v0.6.tar.gz | \
         tar zx -C /usr/local/noVNC --strip-components 1 && \
    rm -rf /tmp/* /var/tmp/*

########################################################
# Customization for user and location
########################################################

ADD image /
ADD conf/ $DOCKER_HOME/.config

RUN mkdir $DOCKER_HOME/.vnc && \
    mkdir $DOCKER_HOME/.log && \
    chown -R $DOCKER_USER:$DOCKER_GROUP $DOCKER_HOME

WORKDIR $DOCKER_HOME
USER root
