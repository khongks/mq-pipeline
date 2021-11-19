#!/bin/bash

cert_name=$1
namespace=$2
secret_name=$3
client_folder=$4
client_kdb_file=$5
tls_crt_file="tls.crt"
tls_key_file="tls.key"
full_client_kdb_file="${client_folder}/${client_kdb_file}"
passphrase="Passw0rd!"

echo "----------------------------------------------------------------------"
echo " INFO: Create tls secret"
echo "----------------------------------------------------------------------"

if [[ -z $cert_name ]]; then
  echo "ERROR: Need to specify param - cert_name"
  exit 1
fi

if [[ -z $namespace ]]; then
  echo "ERROR: Need to specify param - namespace"
  exit 1
fi

if [[ -z $secret_name ]]; then
  echo "ERROR: Need to specify param - secret_name"
  exit 1
fi

if [[ -z $client_folder ]]; then
  echo "ERROR: Need to specify param - client_folder"
  exit 1
fi

if [[ -z $client_kdb_file ]]; then
  echo "ERROR: Need to specify param - client_kdb_file"
  exit 1
fi

echo "----------------------------------------------------------------------"
echo "Create a TLS private key and certificates for ${cert_name}"
echo "----------------------------------------------------------------------"
if [[ -f ${tls_key_file} ]]; then
    rm ${tls_key_file}
fi
if [[ -f ${tls_crt_file} ]]; then
    rm ${tls_crt_file}
fi
openssl req -newkey rsa:2048 -nodes -keyout ${tls_key_file} -subj "/CN=${cert_name}" -x509 -days 3650 -out ${tls_crt_file}

$(dirname $0)/06-create-client-kdb.sh ${full_client_kdb_file} ${cert_name} ${tls_crt_file} ${passphrase}

echo "----------------------------------------------------------------------"
echo "Create a secret ${secret_name} containing TLS certificates from ${tls_crt_file} and ${tls_key_file}"
echo "----------------------------------------------------------------------"

oc get secret -n ${namespace} ${secret_name} -ojson 2>&1
if [ "$?" = "0" ]; then
    echo "Secret ${secret_name} found. Delete and create ${secret_name}"
    oc delete secret ${secret_name} -n ${namespace}
else
    echo "Secret ${secret_name} not found. Create ${secret_name}"
fi
oc create secret tls ${secret_name} --key="${tls_key_file}" --cert="${tls_crt_file}" -n ${namespace}