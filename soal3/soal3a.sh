#!/bin/bash

if [ $# -gt 0 ]
then
  log_directory="$1/Foto.log"
  pic_directory="$1/"
  mkdir $pic_directory
else
  log_directory="Foto.log"
  pic_directory=""
fi

# Directories
new_directory=$(date '+%d-%m-%Y')

# URLs
pic_url="https://loremflickr.com/320/240/kitten"

# Picture count
pic_count=1
max_pic=2

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
  mv -- "$i" "$new"
  let a_rep=a_rep+1
done
