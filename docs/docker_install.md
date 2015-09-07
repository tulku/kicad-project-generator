# Docker installation

This instructions work for Ubuntu 14.04. For other distributions, please check
[the official documentation](https://docs.docker.com/installation/)

We are going to install the latest version of Docker. The packages included with the distribution is pretty outdated.

1. `$ sudo apt-get update`
1. `$ sudo apt-get install linux-image-generic-lts-trusty`
1. `$ sudo reboot`
1. `$ sudo apt-get install curl`
1. `$ curl -sSL https://get.docker.com/ | sh`
