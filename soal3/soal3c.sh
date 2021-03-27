#!/bin/bash

i=$(date "+%--j")
i=$((i % 2))

kucing_url="https://loremflickr.com/320/240/kitten"
kelinci_url="https://loremflickr.com/320/240/bunny"

kucing_folder="Kucing_"$(date "+%d-%m-%Y")
kelinci_folder="Kelinci_"$(date "+%d-%m-%Y")


if [ "$i" -eq "1" ]
then
	# kelinci
	mkdir "$kelinci_folder"
	wget "$kelinci_url" -q
	mv 'bunny' "$kelinci_folder"/	
else
	# kucing
	mkdir "$kucing_folder"
	wget "$kucing_url" -q
	mv 'kitten' "$kucing_folder"/
fi
