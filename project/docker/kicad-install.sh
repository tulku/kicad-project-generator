#!/bin/bash -e

# Set where the 3 source trees will go, use a full path
WORKING_TREES=~/kicad_sources

# CMake Options
OPTS="$$OPTS -DBUILD_GITHUB_PLUGIN=ON"       # needed by $$STABLE revision

# Python scripting enabled
# Most advanced python scripting: you can execute python scripts inside Pcbnew to edit the current loaded board
# mainly for advanced users
OPTS="$$OPTS -DKICAD_SCRIPTING=ON -DKICAD_SCRIPTING_MODULES=ON -DKICAD_SCRIPTING_WXPYTHON=ON"

LIBS_REPO="https://github.com/KiCad/kicad-library.git"
SRCS_REPO="https://github.com/KiCad/kicad-source-mirror.git"

SRCS_COMMIT="${SRCS_COMMIT}"
LIBS_COMMIT="${LIBS_COMMIT}"

rm_build_dir()
{
    local dir="$$1"

    echo "removing directory $$dir"

    if [ -e "$$dir/install_manifest.txt" ]; then
        # this file is often created as root, so remove as root
        rm "$$dir/install_manifest.txt" 2> /dev/null
    fi

    if [ -d "$$dir" ]; then
        rm -rf "$$dir"
    fi
}


cmake_uninstall()
{
    # assume caller set the CWD, and is only telling us about it in $$1
    local dir="$$1"

    cwd=`pwd`
    if [ "$$cwd" != "$$dir" ]; then
        echo "missing dir $$dir"
    elif [ ! -e install_manifest.txt  ]; then
        echo
        echo "Missing file $$dir/install_manifest.txt."
    else
        echo "uninstalling from $$dir"
        make uninstall
        rm install_manifest.txt
    fi
}


# Function set_env_var
# sets an environment variable globally.
set_env_var()
{
    local var=$$1
    local val=$$2

    if [ -d /etc/profile.d ]; then
        if [ ! -e /etc/profile.d/kicad.sh ] || ! grep "$$var" /etc/profile.d/kicad.sh >> /dev/null; then
            echo
            echo "Adding environment variable $$var to file /etc/profile.d/kicad.sh"
            echo "Please logout and back in after this script completes for environment"
            echo "variable to get set into environment."
            sh -c "echo export $$var=$$val >> /etc/profile.d/kicad.sh"
        fi

    elif [ -e /etc/environment ]; then
        if ! grep "$$var" /etc/environment >> /dev/null; then
            echo
            echo "Adding environment variable $$var to file /etc/environment"
            echo "Please reboot after this script completes for environment variable to get set into environment."
            sh -c "echo $$var=$$val >> /etc/environment"
        fi
    fi
}


install()
{
    echo "step 1) make $$WORKING_TREES if it does not exist"
    if [ ! -d "$$WORKING_TREES" ]; then
        mkdir -p "$$WORKING_TREES"
        echo " mark $$WORKING_TREES as owned by me"
        chown -R `whoami` "$$WORKING_TREES"
    fi
    cd $$WORKING_TREES

    echo "step 2) checking out the source code from GitHub repo..."
    if [ ! -d "$$WORKING_TREES/kicad.git" ]; then
        git clone $$SRCS_REPO kicad.git
        ( cd kicad.git ; git checkout $$SRCS_COMMIT )
        echo " source repo to local working tree."
    fi

    echo "step 3) checking out the schematic parts and 3D library repo."
    if [ ! -d "$$WORKING_TREES/kicad-lib.git" ]; then
        git clone $$LIBS_REPO kicad-lib.git
        ( cd kicad-lib.git ; git checkout $$LIBS_COMMIT )
        echo ' kicad-lib checked out.'
    fi

    echo "step 4) compiling source code..."
    cd kicad.git
    if [ ! -d "build" ]; then
        mkdir build && cd build
        cmake $$OPTS ../ || exit 1
    else
        cd build
        # Although a "make clean" is sometimes needed, more often than not it slows down the update
        # more than it is worth.  Do it manually if you need to in this directory.
        # make clean
    fi
    make -j4 || exit 1
    echo " kicad compiled."

    echo "step 5) installing KiCad program files..."
    make install
    echo " kicad program files installed."

    echo "step 6) installing libraries..."
    cd ../../kicad-lib.git
    rm_build_dir build
    mkdir build && cd build
    cmake ../
    make install
    echo " kicad-lib.git installed."

    echo "step 7) check for environment variables..."
    if [ -z "$${KIGITHUB}" ]; then
        set_env_var KIGITHUB https://github.com/KiCad
    fi

    echo
    echo 'All KiCad install steps completed, you are up to date.'
    echo
}


if [ $$# -eq 1 -a "$$1" == "--remove-sources" ]; then
    echo "deleting $$WORKING_TREES"
    rm_build_dir "$$WORKING_TREES/kicad.git/build"
    rm_build_dir "$$WORKING_TREES/kicad-lib.git/build"
    rm -rf "$$WORKING_TREES"
    exit
fi


if [ $$# -eq 1 -a "$$1" == "--install" ]; then
    install
    exit
fi
