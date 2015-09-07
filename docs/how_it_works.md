# How does it work?

This is just a set of bash and Python scripts that complement the Docker system. These scripts do the following:

1. Create the specific Dockerfile which has the instruction of which versions of Kicad we want to use.
1. Create the project directory structure which has a useful bash configuration script (setup.bash)

Docker is capable of creating a minimal Ubuntu 14.04 installation in which we install the specific version of Kicad we want, in complete isolation from the our installation.

## Getting the latest version of Kicad

(this section is outdated!)
These scripts *add the kicad daily ppa* to the host system, but *do not install Kicad on it*. They add the repository to get the name of the latest version of Kicad.

The bash scripts that adds the ppa (if necessary), updates the debian package list and gets the latest Kicad version is `$ ./scripts/get_latest_kicad.sh`



# Launching GUI

Allow X connections from anywhere with `xhost +` on container.

Run docker container with the following extra arguments;
 * `-v /tmp/.X11-unix:/tmp/.X11-unix` - Maps the X11 sockets into the docker container.
 * `-e DISPLAY=$DISPLAY` - Set up the $DISPLAY environment variable.

See http://fabiorehm.com/blog/2014/09/11/running-gui-apps-with-docker/
