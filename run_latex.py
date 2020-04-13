#!/usr/bin/env python

import glob
import os
import shutil
import subprocess
import sys

texlive, latexrun, job_name, main_file, output_file = sys.argv[1:6]
sources = sys.argv[6:]

env = dict(os.environ)
# Generated files (eg. outputs of pdfcrop) are placed under bazel-out/*/bin.
# This references the bin directory so pdflatex can find them. There is
# probably a better way of doing this.
bin_dirs = set()
for source in sources:
    if source.startswith("bazel-out"):
        bin_dirs.add("%s/%s" % (os.getcwd(), "/".join(source.split("/")[:3])))
env["TEXINPUTS"] = ".:%s:" % ":".join(sorted(bin_dirs))

env["PATH"] = "%s:%s" % (os.path.abspath("%s/bin/x86_64" % texlive), env["PATH"])
env["PATH"] = "%s:%s" % (os.path.abspath(texlive), env["PATH"])
env["TEXMFHOME"] = os.path.abspath(texlive)
env["TEXMFVAR"] = os.path.abspath(texlive)
env["SOURCE_DATE_EPOCH"] = "0"

return_code = subprocess.call(
    args=[
        "python3",
        latexrun,
        "--latex-args=-jobname=" + job_name,
        "--latex-cmd=pdflatex",
        "--bibtex-cmd=bibtex",
        "-Wall",
        main_file,
    ],
    env=env,
)

if return_code != 0:
    sys.exit(return_code)
os.rename(job_name + ".pdf", output_file)
