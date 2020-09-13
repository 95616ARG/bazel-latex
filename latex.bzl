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

def latex_document(name, main, srcs = []):
    """Given a TeX file, add rules for compiling and archiving it.
    """

    # PDF generation.
    _latex_pdf(
        name = name,
        srcs = srcs,
        main = main,
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
        srcs = ["@bazel_latex//:get_pdf.sh"],
        data = [name + ".pdf"],
    )

    # Create an arXiv-ready version of the source.
    native.sh_binary(
        name = name + "_getarxivable",
        srcs = ["@bazel_latex//:get_arxivable.sh"],
        data = srcs + ["@arxiv_latex_cleaner//:all"],
    )
