#!/bin/sh

builddir=$BUILD_WORKING_DIRECTORY
cp $1 $builddir/$1
chmod -x+w $builddir/$1
