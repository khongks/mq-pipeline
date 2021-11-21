#!/bin/bash

cert_name=${1:-qm1cert}

cert_folder="cert"
tls_crt_file="tls.crt"
tls_key_file="tls.key"
passphrase="Passw0rd!"

echo "----------------------------------------------------------------------"
echo " INFO: Generate TLS cert and key"
echo "----------------------------------------------------------------------"

echo "----------------------------------------------------------------------"
echo "Create a TLS private key and certificates for ${cert_name} in folder ${cert_folder}"
echo "----------------------------------------------------------------------"

if [[ ! -f ${cert_folder} ]]; then
  mkdir ${cert_folder}
fi
if [[ -f ${cert_folder}/${tls_key_file} ]]; then
  rm ${cert_folder}/${tls_key_file}
fi
if [[ -f ${cert_folder}/${tls_crt_file} ]]; then
  rm ${cert_folder}/${tls_crt_file}
fi

openssl req -newkey rsa:2048 -nodes -keyout ${cert_folder}/${tls_key_file} -subj "/CN=${cert_name}" -x509 -days 3650 -out ${cert_folder}/${tls_crt_file}

#$(dirname $0)/00-create-client-kdb.sh ${client_folder}/${client_kdb_file} ${cert_name} ${cert_folder}/${tls_crt_file} ${passphrase}