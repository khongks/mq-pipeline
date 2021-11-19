#!/bin/bash

# https://colinpaice.blog/setting-up-tls-for-mq-with-your-own-certificate-authority-using-ikeyman/
# https://www.ibm.com/support/pages/ibm-mq-troubleshooting-common-tls-ssl-errors#9633
# https://www.ibm.com/docs/en/ibm-mq/8.0?topic=wstuws-specifying-key-repository-location-mq-mqi-client-unix-linux-windows-systems

client_kdb_file=$1
cert_name=$2
cert_file=$3
passphrase=$4

echo "----------------------------------------------------------------------"
echo "INFO: Create a client key database"
echo "----------------------------------------------------------------------"

if [[ -z $client_kdb_file ]]; then
  echo "ERROR: Need to specify param - client_kdb_file"
  exit 1
fi

if [[ -z $cert_name ]]; then
  echo "ERROR: Need to specify param - cert_name"
  exit 1
fi

if [[ -z $cert_file ]]; then
  echo "ERROR: Need to specify param - cert_file"
  exit 1
fi

echo "----------------------------------------------------------------------"
echo "INFO: Create a client key database ${client_kdb_file} with ${cert_file} using label ${cert_name}" 
echo "----------------------------------------------------------------------"
if [[ -f ${client_kdb_file} ]]; then
    # remove suffix
    client_files=${client_kdb_file%.*}
    echo ${client_files}
    echo "Found ${client_kdb_file}. Delete all ${client_files}.* and create ${client_kdb_file}"
    rm ${client_files}.*
fi
runmqakm -keydb -create -db ${client_kdb_file} -pw ${passphrase} -type cms -stash

echo "----------------------------------------------------------------------"
echo "INFO: Add label ${cert_name}, cert file: ${cert_file}"
echo "----------------------------------------------------------------------"
runmqakm -cert -add -db ${client_kdb_file} -label ${cert_name} -file ${cert_file} -format ascii -stashed
runmqakm -cert -setdefault -db ${client_kdb_file} -type cms -stashed -label ${cert_name}
runmqakm -cert -list -db ${client_kdb_file} -type cms -stashed
runmqakm -cert -details -db ${client_kdb_file} -type cms -stashed -label ${cert_name}