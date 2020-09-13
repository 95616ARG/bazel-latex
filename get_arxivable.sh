#!/bin/sh

out_name=$PWD/./$1
paper_dir=$(mktemp -d)

cp -LR * $paper_dir
rm $paper_dir/$(basename $0)
python3 external/arxiv_latex_cleaner/arxiv_latex_cleaner.py $paper_dir

cd $(echo $paper_dir)_arXiv
tar -czvf $out_name *
