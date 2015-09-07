
FROM ubuntu:14.04

MAINTAINER lucas.chiesa@gmail.com

COPY simple-add-ppa.sh /usr/local/bin/

# Add the kicad PPA for latext wxwidget, update packages, install build dependencies
RUN \
  ls -l /usr/local/bin && \
  simple-add-ppa.sh ppa:js-reynaud/ppa-kicad 910F124E trusty && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y curl git sed python-pip python-dev libyaml-dev \
  build-essential cmake cmake-curses-gui debhelper doxygen grep libbz2-dev \
  libcairo2-dev libglew-dev libssl-dev libwxgtk3.0-dev python-wxgtk3.0-dev swig \
  bzr bzrtools

# Install wstool for library installation
RUN pip install -U wstool

COPY download-kicad-library.sh /usr/local/bin/
COPY kicad_libs.rosinstall /usr/local/bin/

# Build kicad
RUN bzr whoami "Nobody <name@nobody.com>"
COPY kicad-install.sh /usr/local/bin/
RUN kicad-install.sh --install
# Delete kicad sources
RUN kicad-install.sh --remove-sources

# Add the kicad user
RUN adduser --disabled-password --gecos "" kicad
USER kicad
# Download the .pretty component libraries
RUN download-kicad-library.sh
ENV KISYSMOD /home/kicad/kicad_libs/library-repos

# Configuration and start up
VOLUME ["/home/kicad/.kicad"]
WORKDIR /home/kicad/
ENTRYPOINT ["kicad"]
