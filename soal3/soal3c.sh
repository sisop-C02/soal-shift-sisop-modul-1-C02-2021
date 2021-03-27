#!/bin/bash

# Date handling
i=$(date "+%--j")
i=$((i % 2))

# URLs
kucing_url="https://loremflickr.com/320/240/kitten"
kelinci_url="https://loremflickr.com/320/240/bunny"
# Directories
kucing_folder="Kucing_"$(date "+%d-%m-%Y")
kelinci_folder="Kelinci_"$(date "+%d-%m-%Y")

# Date branching
if [ "$i" -eq "1" ]
then
	# kelinci
	mkdir $kelinci_folder
  pic_url=$kelinci_url
  pic_directory="$kelinci_folder/"
else
	# kucing
	mkdir $kucing_folder
  pic_url=$kucing_url
  pic_directory="$kucing_folder/"
fi
log_directory="$pic_directory/Foto.log"

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
  mv -- "$i" "$new"
  let a_rep=a_rep+1
done