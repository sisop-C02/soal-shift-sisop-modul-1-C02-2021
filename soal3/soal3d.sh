#!/bin/bash

# zip the folders
password=$(date "+%m%d%Y")
zip -P $password -r Koleksi.zip */

# delete the folders
rm -R -- */

# opsi 1
# password=$(date "+%m%d%Y")
# zip -P $password -r Koleksi.zip Kucing_* Kelinci_*
# rm -R -- Kucing_* Kelinci_*