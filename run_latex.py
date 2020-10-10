#!/usr/bin/env python

"""Build a LaTeX project.

Two invocations are supported:

1) run_latex.py [texlive] [latexrun] [jobname] [mainfile].tex [outfile].pdf [sources...]
2) run_latex.py [texlive] [latexrun] [jobname] [mainfile].tex -- [sources...] -- [command...]

The first will build [outfile].pdf from [mainfile].tex and the [sources...].
This is used to build the PDF file for the [name]_getpdf rules.

The second will build the paper, place [jobname].bbl in the current directory,
then call [command...]. This is used to build the bbl file for the
[name]_getarxivable rules.
"""

import glob
import os
import shutil
import subprocess
import sys

texlive, latexrun, compiler, job_name, main_file, output_file = sys.argv[1:7]
sources = sys.argv[6:]
if output_file == "--":
    run_after = sources[sources.index("--"):][1:]
    sources = sources[:sources.index("--")]

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
        "--latex-cmd=" + compiler,
        "--bibtex-cmd=bibtex",
        "-Wall",
        main_file,
    ],
    env=env,
)

if return_code != 0:
    sys.exit(return_code)

if output_file != "--":
    os.rename(job_name + ".pdf", output_file)
else:
    # Run the run_after script.
    os.rename("latex.out/" + job_name + ".bbl", job_name + ".bbl")
    return_code = subprocess.call(
        args=run_after,
        env=env,
    )
