#!/bin/bash

pdfcrop=$1
texlive=$2
if [[ $texlive =~ ^[^/].*$ ]]; then
    texlive=$PWD/$texlive
fi
echo "Using TeXLive installation: $texlive"
uncropped=$3
output=$4

PATH=$texlive/bin/x86_64:$PATH
PDFCROP=$PWD/$pdfcrop
$PDFCROP $uncropped $output --pdftex
