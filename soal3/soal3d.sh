#!/bin/bash

folders=$(ls -F | grep "/")
for f in "$folders"
do
	echo $f
done
password=$(date "+%d%m%Y")

zip -P $password Koleksi.zip */ 

