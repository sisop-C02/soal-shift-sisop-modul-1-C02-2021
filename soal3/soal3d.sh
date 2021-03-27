#!/bin/bash

password=$(date "+%m%d%Y")
zip -P $password -r Koleksi.zip */

rm -R -- */