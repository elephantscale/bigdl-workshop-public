#!/bin/bash

## install nbconvert as
##      conda install nbconvert
##              or
##      pip install nbconvert

## cleanup html
find . -name "*.html" -print0 | xargs -0 rm -f

## convert ipynb notebooks into HTML
notebooks=$(find notebooks -type f -name "*.ipynb" | grep -v ".ipynb_checkpoints" )

jupyter nbconvert ${notebooks}

## Change all the links from README.html
sed 's/ipynb/html/g' < notebooks/README.html > notebooks/a.html
mv -f notebooks/a.html  notebooks/README.html

# create a zipfile

zip_file_name=$(basename `pwd`)
rm -f *.zip
zip -x '*.DS_Store*'  -x "*.log" -x '*.git*'  -x '*zip*'  -x '*gz*' -x '*news20/glove.6B*' -x '*metastore_db*' -x '*out' -x '*.ipynb_checkpoints*' -x '*not-using*'  -x '*.jpg' -x '*.png'   -r "$zip_file_name" .


#git archive --format=zip HEAD -o bigdl-labs.zip
