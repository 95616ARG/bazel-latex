def _pdf_crop_impl(ctx):
    texlive_path = ctx.var.get("TEXLIVE_FULL_DIR", None)
    if texlive_path == None:
        fail("Please run setup_texlive.sh to set TEXLIVE_FULL_DIR.")
    uncropped = ctx.attr.uncropped.files.to_list()[0]
    ctx.actions.run(
        mnemonic = "PDFCrop",
        executable = "bash",
        use_default_shell_env = True,
        arguments = [
            ctx.files._pdf_crop_wrapper[0].path,
            texlive_path,
            uncropped.path,
            ctx.outputs.output.path,
        ],
        inputs = depset(
            direct = (ctx.files._pdf_crop_wrapper + [uncropped]),
        ),
        outputs = [ctx.outputs.output],
    )

_pdf_crop = rule(
    attrs = {
        "uncropped": attr.label(
            allow_files = True,
        ),
        "output": attr.output(),
        "_pdf_crop_wrapper": attr.label(
            allow_files = True,
            default = "@bazel_latex//:pdfcrop.sh",
        ),
    },
    implementation = _pdf_crop_impl,
)

def pdfcrop(name = "pdfcrop", visibility = [], uncropped = []):
    for path in uncropped:
        if not path.endswith(".pdf"):
            fail
    for i, path in enumerate(uncropped):
        _pdf_crop(
            name = path[:-4] + "-cropper",
            uncropped = path,
            output = path[:-4] + "-crop.pdf",
            visibility = visibility,
        )
