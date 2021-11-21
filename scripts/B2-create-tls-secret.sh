#!/bin/bash

cert_name=$1
namespace=$2
secret_name=$3

cert_folder="certs"
tls_crt_file="tls.crt"
tls_key_file="tls.key"

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

echo "----------------------------------------------------------------------"
echo "Create a secret ${secret_name} for TLS certificates from ${cert_folder}/${tls_crt_file} and ${cert_folder}/${tls_key_file}"
echo "----------------------------------------------------------------------"

oc get secret -n ${namespace} ${secret_name} -ojson 2>&1
if [ "$?" = "0" ]; then
    echo "Secret ${secret_name} found. Delete and create ${secret_name}"
    oc delete secret ${secret_name} -n ${namespace}
else
    echo "Secret ${secret_name} not found. Create ${secret_name}"
fi
oc create secret tls ${secret_name} --key="${cert_folder}/${tls_key_file}" --cert="${cert_folder}/${tls_crt_file}" -n ${namespace}