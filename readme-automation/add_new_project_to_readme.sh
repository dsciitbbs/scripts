#!/usr/local/bin/bash

cd ..

list=(*/)

heading="## Scripts"
file="README.md"

dir="readme-automation/"

for dir in "${list[@]}";
do
	echo $dir
	# check the readme
	if ggrep -q "${dir::-1}" $file
	then
		echo "found"
		continue
	else
		# add to readme
		echo "not found"
		gsed $file -e "/$heading/a - ${dir::-1}" > temp.md
		mv temp.md $file
	fi
done

git add .
git commit -m 'Updated README'
git push