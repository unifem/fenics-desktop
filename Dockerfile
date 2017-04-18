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
# Install FreeCAD and Gmsh
RUN add-apt-repository ppa:freecad-maintainers/freecad-stable && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-server \
        net-tools \
        spyder3 \
        g++ \
        \
        xserver-xorg-video-dummy \
        lxde \
        dbus-x11 \
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
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
    python2 get-pip.py && \
    pip2 install --no-cache-dir setuptools && \
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

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN mkdir -p $DOCKER_HOME/.vnc && \
    mkdir -p $DOCKER_HOME/.ssh && \
    mkdir -p $DOCKER_HOME/.log && touch $DOCKER_HOME/.log/vnc.log && \
    echo "export NO_AT_BRIDGE=1" >> /home/$DOCKER_USER/.bashrc && \
    chown -R $DOCKER_USER:$DOCKER_GROUP $DOCKER_HOME

WORKDIR $DOCKER_HOME
USER root
