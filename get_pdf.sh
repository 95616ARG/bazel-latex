#!/bin/sh
filename="$(find . -name '*.pdf')"
builddir=$BUILD_WORKING_DIRECTORY
cp $filename $builddir/$filename
chmod -x+w $builddir/$filename
