load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def latex_repositories():
    """Adds external dependencies necessary for Bazel-LaTeX.
    """
    http_archive(
        name = "bazel_latex_latexrun",
        build_file_content = "exports_files([\"latexrun\"])",
        patches = [
            "@bazel_latex//:patches/latexrun-force-colors",
            "@bazel_latex//:patches/latexrun-pull-21",
            "@bazel_latex//:patches/latexrun-pull-47",
            "@bazel_latex//:patches/latexrun-pull-61",
            "@bazel_latex//:patches/latexrun-pull-62",
        ],
        sha256 = "4e1512fde5a05d1249fd6b4e6610cdab8e14ddba82a7cbb58dc7d5c0ba468c2a",
        strip_prefix = "latexrun-38ff6ec2815654513c91f64bdf2a5760c85da26e",
        url = "https://github.com/aclements/latexrun/archive/38ff6ec2815654513c91f64bdf2a5760c85da26e.tar.gz",
    )

    http_archive(
        name = "arxiv_latex_cleaner",
        build_file_content = """filegroup(name = "all", srcs = glob(["**"]), visibility = ["//visibility:public"])""",
        sha256 = "770c65993c964405bb5362ee75039970434ef395872356980e470b6b044ac427",
        strip_prefix = "arxiv-latex-cleaner-ea4db65744837bb1205a4fd14b56244b2e639c34",
        url = "https://github.com/google-research/arxiv-latex-cleaner/archive/ea4db65744837bb1205a4fd14b56244b2e639c34.tar.gz",
    )
