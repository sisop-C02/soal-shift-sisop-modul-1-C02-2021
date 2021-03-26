#!/bin/bash

i=$(date "+%-e")
i=$((i % 2))

kucing_url="https://loremflickr.com/320/240/kitten"
kelinci_url="https://loremflickr.com/320/240/bunny"

kucing_folder="Kucing_"$(date "+%d-%m-%Y")
kelinci_folder="Kucing_"$(date "+%d-%m-%Y")

mkdir "$kucing_folder"
mkdir "$kelinci_folder"

if [ "$i" -eq "1" ]
then
	# kelinci
	wget "$kelinci_url" -q
	mv 'bunny' "$kelinci_folder"/	
else
	# kucing
	wget "$kucing_url" -q
	mv 'kitten' "$kucing_folder"/
fi
