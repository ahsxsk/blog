#!/bin/bash
file=`ls *.md`;
#echo $file
for item in $file
do
filename=${item}
echo $filename
#sed -i "s/search('channel')/search('${filename}')/g" $item
#gsed -i '1 ititle:\ndate: 2017-11-11 13:09:04\ntags: []\n------------------' $item
gsed -i 's/tags/categories/g' $item
done
