#!/bin/bash

texlive=$1
if [[ $texlive =~ ^[^/].*$ ]]; then
    texlive=$PWD/$texlive
fi
echo "Using TeXLive installation: $texlive"
uncropped=$2
output=$3

PATH=$texlive/bin/x86_64:$PATH
pdfcrop $uncropped $output --pdftex
