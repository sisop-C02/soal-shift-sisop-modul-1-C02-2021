#!/bin/bash

echo $(pwd)
folders=$(ls -F | grep "/")
for f in "$folders"
do
	echo $f
done
password=$(date "+%d%m%Y")
echo $password
zip Koleksi.zip */ --password biji

