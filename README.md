# What is this?

Kicad is evolving very rapidly, which is a very good thing! However, it is quite frustrating that when opening a project we worked on some time ago, with an older version of Kicad, we end up with broken schematics or worse.

We want to be able to use always the latest version of Kicad when starting a new project, and then be able to freeze it for that project. So, if we stop working on it for some time and then go back, always have the same Kicad version (and libraries) that we used to create the design.

To achieve this we use Docker to create and isolated environment where we can install a particular version of Kicad and use always the same one.

# Usage

You need to have docker installed on your computer. You can use [this summarized instructions](docs/docker_install.md).

## Creating a new project

To simplify as much as possible the creation of a new project there is an automated script that creates an new project directory with the ready to use Dockerfile.

To use it:

`$ ./new_kicad_project <path to where we want the project>`

For example, if we want to create a project named 'Tiburoncin' in our home directory, we would run:

`$ ./new_kicad_project ~/Tiburoncin`

That will create the Tiburoncin directory and inside it the docker files needed to build the image with the latest Kicad. It will also:

1. Add some useful files
1. Build the Docker image
1. Create a git repository in that directory

## How to use the project

Once we created the project, we `cd` into the new directory and we will find the following files:

```
docker/
pcb/
setup.bash
README.md
```

To start working on the PCB we:

1. `$ source setup.bash`
1. `$ docker_kicad`

Inside the kicad instance you will find that the paths are not the same. The program will be running from the home directory of a kicad *user*. In that home directory, you will find a folder with the same name as the project you created. That is the *same* project folder that you just created.

## How to use an existing project

When starting to work on an existing project (a project we just cloned from github for example), we need to follow these steps only once:

1. `$ source setup.bash`
1. `$ cd docker`
1. `$ docker_build` (wait a lot of time...)

Afther that, we start kicad (after source the setup.bash)

1. `$ dockerr_kicad`

# More information

You can read about how this works on [this document](docs/how_it_works.md)
