#!/bin/bash

if [ $# -ne 1 ] && [ $# -ne 2 ]; then
    echo "This is $(basename $0). Usage:"
    echo "$(basename $0) [/path/to/texlive2019-20190410-iso/mounted] [/path/to/install/directory]"
    exit 1
fi

texlive_mount=$1
install_dir=$2

if [[ ! $install_dir =~ ^/ ]]
then
    echo "Please use an absolute path for the install directory."
    exit 1
fi

read -p "Installing TeX Live. This will *OVERWRITE* $install_dir. Continue? [y/N] " -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    rm -rf $install_dir
    mkdir -p $install_dir

    infile=$(mktemp)
    echo "I" > $infile

    if which tlmgr
    then
        echo "I" >> $infile
    fi

    pushd $texlive_mount
    cat $infile | \
    TEXLIVE_INSTALL_PREFIX=$install_dir \
    ./install-tl -no-gui -portable -scheme full
    popd

    rm $infile

    # TeXLive will make different bin directories depending on the
    # OS; this overrides that to be just x86_64.
    tmpdir=$(mktemp -d)
    mv $install_dir/bin/*/* $tmpdir
    rm -rf $install_dir/bin/*
    mkdir $install_dir/bin/x86_64
    mv $tmpdir/* $install_dir/bin/x86_64
    rm -rf $tmpdir

    echo "Success!"
    echo "Writing Installation Directory to $HOME/.bazelrc"
    echo "build --define TEXLIVE_FULL_DIR=$install_dir" >> ~/.bazelrc
    echo "run --define TEXLIVE_FULL_DIR=$install_dir" >> ~/.bazelrc
else
    echo "Aborting."
    exit 1
fi
