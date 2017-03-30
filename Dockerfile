# Builds a Docker image for FEniCS in a Desktop environment
# with Ubuntu, LXDE, and Python 2.
#
# The built image can be found at:
#   https://hub.docker.com/r/multiphysics/fenics-desktop
#
# Authors:
# Xiangmin Jiao <xmjiao@gmail.com>

FROM quay.io/fenicsproject/stable
LABEL maintainer "Xiangmin Jiao <xmjiao@gmail.com>"

USER root
WORKDIR /tmp

ENV DEBIAN_FRONTEND noninteractive

# Install some required system tools and packages for X Windows
# We install firefox and make --no-remote to be default
# Install FreeCAD, Gmsh, python-vtk
RUN add-apt-repository ppa:freecad-maintainers/freecad-stable && \
    apt-get update && \
    apt-get upgrade -y -o Dpkg::Options::="--force-confold" && \
    apt-get install -y --no-install-recommends \
        openssh-server \
        net-tools \
        python-pip \
        python-dev \
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
        firefox \
	xpdf \
	\
	freecad \
        python-vtk \
        gmsh && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    sed -i 's/MOZ_APP_NAME "\$@"/MOZ_APP_NAME --no-remote "\$@"/' /usr/bin/firefox && \
    pip2 install -U pip \
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
ADD conf/ /home/fenics/.config

ENV DOCKER_USER=multiphysics
ENV DOCKER_GROUP=$DOCKER_USER \
    DOCKER_HOME=/home/$DOCKER_USER \
    HOME=/home/$DOCKER_USER

# Change the default timezone to America/New_York
# Set up user so that we do not run as root
RUN echo "America/New_York" > /etc/timezone && \
    ln -s -f /usr/share/zoneinfo/America/New_York /etc/localtime && \
    mv /home/fenics /home/$DOCKER_USER && \
    useradd -m -s /bin/bash -G sudo,docker_env $DOCKER_USER && \
    echo "$DOCKER_USER:docker" | chpasswd && \
    echo "$DOCKER_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    mkdir $DOCKER_HOME/.vnc && \
    mkdir $DOCKER_HOME/.log && \
    chown -R $DOCKER_USER:$DOCKER_GROUP $DOCKER_HOME

WORKDIR $DOCKER_HOME
USER root

ENTRYPOINT ["/sbin/my_init","--quiet","--","/sbin/setuser","multiphysics","/bin/bash","-l","-c"]
CMD ["/bin/bash","-i"]
