#!/bin/bash

password=$(date "+%d%m%Y")
zip -P $password -r Koleksi.zip */

