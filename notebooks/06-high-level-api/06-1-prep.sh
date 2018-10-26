#!/bin/bash


# 1. Get Data
data_file='https://s3.amazonaws.com/elephantscale-public/bigdl/cat-dog.zip'
cat_dog_zip="../../data/cat-dog.zip"
if [ ! -f "$cat_dog_zip" ] ; then
        echo "downloading $data_file"
	    wget -O $cat_dog_zip   $data_file
else
        echo "$cat_dog_zip exists"
fi

if [ ! -d "../../data/cat-dog" ] ; then
        echo "unzipping cat-dog.zip"
        (cd ../../data/; unzip -q cat-dog.zip)
fi

rm -rf  ../../data/cat-dog/sample/train
mkdir -p ../../data/cat-dog/sample/train

echo "extracting sample cat/dog images"
cp ../../data/cat-dog/data/train/cats/cat.[7]*  ../../data/cat-dog/sample/train/
cp ../../data/cat-dog/data/train/dogs/dog.[7]*  ../../data/cat-dog/sample/train/

# for full dataset do this
#echo "extracting full set of cat/dog images"
#cp ../cat-dog/data/train/cats/cat.*    dogs-vs-cats/train/
#cp ../cat-dog/data/train/dogs/dog.*    dogs-vs-cats/train/
