#!/bin/bash

client_kdb_file="client/clientkey.kdb"

if [[ -f ${client_kdb_file} ]]; then
    # remove suffix
    client_files=${client_kdb_file%.*}
    echo ${client_files}
    echo "Found ${client_kdb_file}. Delete all ${client_files}.* and create ${client_kdb_file}"
    rm ${client_files}.*
fi