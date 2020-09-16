# Bazel-LaTeX

This repository provides [Bazel](https://bazel.build/) rules for LaTeX.  This
is a heavily modified fork of
[ProdriveTechnologies/bazel-latex](https://github.com/ProdriveTechnologies/bazel-latex).

## Using these Rules
### Step 1: Installing TeX Live
To standardize the install base across all machines, please follow these
instructions precisely:

1. Acquire a copy of `texlive2019-20190410.iso` which can be downloaded
   [here](http://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2019/texlive2019-20190410.iso).
2. Mount the ISO. This process differs depending on the operating system you
   are using. I will assume that you have mounted in `/mnt/texlive`, so that
   `/mnt/texlive/install-tl` exists.
3. Decide where you want to install TeX Live to. For example, I will assume you
   want to install to `/home/matthew/apps/texlive`.
4. Run the `setup_texlive.sh` script. Using the path assumptions above, this
   would look like `./setup_texlive.sh /mnt/texlive
   /home/matthew/apps/texlive`.
5. Unmount the iso.

Note that the `setup_texlive.sh` script will write the install directory to
`$HOME/.bazelrc` so the rules can automatically find the installation. If you
ever move the installation, you will have to update `$HOME/.bazelrc`.

For example, on an Ubuntu machine these steps corresponded to the following commands:
```bash
cd ~/Downloads
curl -OL http://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2019/texlive2019-20190410.iso
mkdir /home/user/texlive-iso
sudo mount -o loop -t iso9660 texlive2019-20190410.iso /home/user/texlive-iso
cd /home/user/bazel-latex # Clone of this repository.
./setup_texlive.sh /home/user/texlive-iso /home/user/texlive-full-bazel
sudo umount /home/user/texlive-iso
rm -rf /home/user/texlive-iso
```
after which you should be able to follow the rest of the instructions to build
a paper.

### Step 2: Using the Bazel Rules
Use the following `WORKSPACE` (modifying `name` as desired):

```python
workspace(name = "your_workspace_name")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

git_repository(
    name = "bazel_latex",
    commit = "{COMMIT_GOES_HERE}",
    remote = "https://github.com/95616ARG/bazel-latex.git",
)

load("@bazel_latex//:repositories.bzl", "latex_repositories")
latex_repositories()
```

Then, in the `BUILD` file of your project, add the following:

```python
load("@bazel_latex//:latex.bzl", "latex_document")

latex_document(
    name = "main",
    srcs = glob([
        "*.tex",
        "*.bib",
        "*.sty",
    ]) + [
        # Other requirements.
    ],
    main = "main.tex",
)
```

### Step 3: Building your Paper
Every `latex_document` rule creates multiple targets:

* `bazel build [name]` will build the PDF, but it won't be directly accessible.
* `bazel run [name]_view` will display the PDF in a graphical viewer.
* `bazel run [name]_getpdf` will copy the PDF into the corresponding directory.
* `bazel build [name]_arxivable` will create an arXiv-ready version of the
  source using
  [arxiv-latex-cleaner](https://github.com/google-research/arxiv-latex-cleaner),
  but it won't be directly accessible in this directory.
* `bazel run [name]_getarxivable` will copy the arXiv-ready version of the
  source into the current directory.

Additionally, a `dblpify` script is provided to interactively replace BibTeX
entries with standardized DBLP ones. It can be run on a file `main.bib` like
so:
```bash
bazel run @bazel_latex//:dblpify -- main.bib
```
Producing an output file `main.dblp.bib`. Note that this script assumes you
have installed in your system Python the packages: `bibtexparser`, `pandas`,
`requests`, and `beautifulsoup`. Our script is based on the wonderful
[dblp-pub](https://github.com/sebastianGehrmann/dblp-pub) library.

## Goals
These rules are designed to achieve the following goals:

* Reproducible builds. Accomplished by having everyone install the same version
  of TeX Live 2019-full. This is harder than it sounds, as TeX Live and CTAN do
  not keep historic versions of packages in any readily-available mirrors, so
  there's no good way to 'pin versions' other than installing a particular
  (full) version of TeX Live and keeping it that way.
* Easily reference new packages. Accomplished by installing an entire `full`
  scheme of TeX Live. This is also harder than it sounds. The original
  `bazel-latex` relied on manual effort to catalog the dependencies of every
  package one wishes to use. To do that for all of the packages even some base
  conference templates would need was daunting. Earlier versions of this
  project installed a `base` copy of TeX Live and then allowed the user to
  specify extra packages to be installed to a per-project usertree through
  `tlmgr`, but that was cumbersome and prone to failure because packages can
  update (see above re: pinning versions) and many don't seem to list
  dependencies accurately to `tlmgr`.
* Relatively light on resource use. This is accomplished by having one TeX Live
  installation shared by all `bazel-latex` projects.
* Easily utilize tools such as `pdfcrop` and `arxiv-latex-cleaner`.

## Tested Operating Systems
We have tested these Bazel-LaTeX rules on the following operating systems:

* Ubuntu 19.10
* Ubuntu 18.04
* Ubuntu 16.04
* macOS Catalina

## Source, Licensing, and Modifications from Original
This project started as a fork of
[ProdriveTechnologies/bazel-latex](https://github.com/ProdriveTechnologies/bazel-latex).
Since then, we have made significant changes to the goals and implementations
of the project, which are partially summarized below:

* We no longer use the ProdriveTechnologies 'modular tex installation,'
  instead using one global, full copy of TeX Live specified by the
  `TEXLIVE_FULL_DIR` flag Bazel define key.
* There are added `getarxivable` and `pdfcrop` crop rules to produce
  arxiv-ready source files and cropped PDF figures automatically.

As detailed in the LICENSE file, the original codebase is licensed under the
Apache 2.0 license. To the fullest extent possible, all additional code in this
repository (written by the Davis Automated Reasoning Group) is licensed under
the MIT (Expat) license.
