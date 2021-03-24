#!/bin/bash

# Directories
log_directory="/home/jaglfr/FotoKucing/Foto.log"
pic_directory="/home/jaglfr/FotoKucing/"
new_directory=~/soal3/$(date '+%Y-%m-%d')

# URLs
pic_url="https://loremflickr.com/320/240/kitten"

# Picture count
pic_count=1
max_pic=23

# Download pics and fill the log
while [ $pic_count -le $max_pic ]
do
    wget -a $log_directory -O $pic_directory$pic_count".jpeg" $pic_url
    let pic_count+=1
done

# Detect and delete duplicates
declare -A arr
shopt -s globstar

for file in $pic_directory*; do
  [[ -f "$file" ]] || continue
   
  read cksm _ < <(md5sum "$file")
  if ((arr[$cksm]++)); then 
    rm $file
  fi
done

# Rename files
a_rep=1
for i in $pic_directory*.jpeg; do
  new=$(printf $pic_directory"Koleksi_%02d" "$a_rep")
  mv -i -- "$i" "$new"
  let a_rep=a_rep+1
done

# Moving files
mkdir "$new_directory"

for i in $pic_directory*; do
  mv -i -- "$i" "$new_directory"
done
