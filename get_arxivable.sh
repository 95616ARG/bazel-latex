#!/bin/sh

out_name=$(basename $0).tar.gz
build_dir=$BUILD_WORKING_DIRECTORY
paper_dir=$(mktemp -d)

cp -LRr * $paper_dir
rm $paper_dir/$(basename $0)
python3 external/arxiv_latex_cleaner/arxiv_latex_cleaner.py $paper_dir

cd $(echo $paper_dir)_arXiv
tar -czvf $build_dir/$out_name *
