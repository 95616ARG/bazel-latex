"""Defines latex_document(...) macro.
"""

def _latex_pdf_impl(ctx):
    """Rule to build a single PDF file.
    """
    texlive_path = ctx.var.get("TEXLIVE_FULL_DIR", None)
    if texlive_path == None:
        fail("Please run setup_texlive.sh to set TEXLIVE_FULL_DIR.")
    ctx.actions.run(
        mnemonic = "LaTeX",
        executable = "python",
        use_default_shell_env = True,
        arguments = [
            ctx.files._run_script[0].path,
            texlive_path,
            ctx.files._latexrun[0].path,
            ctx.attr.compiler,
            ctx.label.name,
            ctx.files.main[0].path,
            ctx.outputs.out.path,
        ] + [src.path for src in ctx.files.srcs],
        inputs = depset(
            direct = (ctx.files.main + ctx.files.srcs + ctx.files._latexrun +
                      ctx.files._run_script),
        ),
        outputs = [ctx.outputs.out],
    )

_latex_pdf = rule(
    attrs = {
        "main": attr.label(allow_files = True),
        "srcs": attr.label_list(allow_files = True),
        "compiler": attr.string(default = "pdflatex"),
        "_latexrun": attr.label(
            allow_files = True,
            default = "@bazel_latex_latexrun//:latexrun",
        ),
        "_run_script": attr.label(
            allow_files = True,
            default = "@bazel_latex//:run_latex.py",
        ),
    },
    outputs = {"out": "%{name}.pdf"},
    implementation = _latex_pdf_impl,
)

def _arxivable_impl(ctx):
    """Rule to run arxiv-latex-cleaner and produce a .tar.gz of the sources.
    """
    texlive_path = ctx.var.get("TEXLIVE_FULL_DIR", None)
    if texlive_path == None:
        fail("Please run setup_texlive.sh to set TEXLIVE_FULL_DIR.")
    ctx.actions.run(
        mnemonic = "Cleaning",
        executable = "python",
        use_default_shell_env = True,
        arguments = [
            ctx.files._run_script[0].path,
            texlive_path,
            ctx.files._latexrun[0].path,
            ctx.attr.compiler,
            ctx.files.main[0].path.replace(".tex", ""),
            ctx.files.main[0].path,
            "--",
            ctx.files._arxiv_script[0].path,
            ctx.outputs.out.path,
            "--",
        ] + [src.path for src in ctx.files.srcs],
        inputs = depset(
            direct = (ctx.files.main + ctx.files.srcs + ctx.files._latexrun +
                      ctx.files._run_script + ctx.files._arxiv_script +
                      ctx.files._arxiv_latex_cleaner),
        ),
        outputs = [ctx.outputs.out],
    )

_arxivable = rule(
    attrs = {
        "main": attr.label(allow_files = True),
        "srcs": attr.label_list(allow_files = True),
        "compiler": attr.string(default = "pdflatex"),
        "_latexrun": attr.label(
            allow_files = True,
            default = "@bazel_latex_latexrun//:latexrun",
        ),
        "_run_script": attr.label(
            allow_files = True,
            default = "@bazel_latex//:run_latex.py",
        ),
        "_arxiv_script": attr.label(
            allow_files = True,
            default = "@bazel_latex//:get_arxivable.sh",
        ),
        "_arxiv_latex_cleaner": attr.label(
            allow_files = True,
            default = "@arxiv_latex_cleaner//:all",
        ),
    },
    outputs = {"out": "%{name}.tar.gz"},
    implementation = _arxivable_impl,
)

def latex_document(name, main, srcs = [], compiler = "pdflatex"):
    """Given a TeX file, add rules for compiling and archiving it.
    """

    # PDF generation.
    _latex_pdf(
        name = name,
        srcs = srcs,
        main = main,
        compiler = compiler,
    )

    # Convenience rule for viewing PDFs.
    native.sh_binary(
        name = name + "_view",
        srcs = ["@bazel_latex//:view_pdf.sh"],
        data = [name + ".pdf"],
    )

    # Copy the PDF into the main working directory.
    native.sh_binary(
        name = name + "_getpdf",
        srcs = ["@bazel_latex//:get_file.sh"],
        args = [name + ".pdf"],
        data = [name + ".pdf"],
    )

    # Create an arXiv-ready version of the source.
    _arxivable(
        name = name + "_arxivable",
        srcs = srcs,
        main = main,
        compiler = compiler,
    )

    # Copy the .tar.gz into the main working directory.
    native.sh_binary(
        name = name + "_getarxivable",
        srcs = ["@bazel_latex//:get_file.sh"],
        args = [name + "_arxivable.tar.gz"],
        data = [name + "_arxivable.tar.gz"],
    )
