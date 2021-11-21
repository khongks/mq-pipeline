#!/bin/bash

workdir=$(dirname $0)

name=${1:-qm1}
namespace=${2:-mq}
channel=${3:-SECUREQMCHL}

cert_name=${name}cert
qmgr_name=$(echo ${name} | tr '[:lower:]' '[:upper:]')
client_folder="client"
ccdt_file="ccdt.json"
client_kdb_file="clientkey.kdb"
cert_file="tls.crt"

echo "----------------------------------------------------------------------"
echo " INFO: Post deploy"
echo "----------------------------------------------------------------------"

${workdir}/C1-create-ccdt.sh ${qmgr_name} ${channel} ${cert_name} ${ccdt_file}

${workdir}/C2-create-client-script.sh ${client_folder} ${ccdt_file} ${client_kdb_file} ${cert_name} ${qmgr_name}

#passphrase="Passw0rd!"
#${workdir}/C3-create-client-kdb.sh ${client_folder}/${client_kdb_file} ${cert_name} certs/${cert_file} ${passphrase}

# print web console ui url
echo ''
echo 'URL: '
oc get queuemanager ${name} -n ${namespace} --output jsonpath='{.status.adminUiUrl}'
# https://cpd-tools.itzroks-3100015379-bry0xt-6ccd7f378ae819553d37d5f2ee142bd6-0000.au-syd.containers.appdomain.cloud/integration/messaging/mq/qm1-ibm-mq

echo ''
echo 'Password: '
# print password
oc get secret ibm-iam-bindinfo-platform-auth-idp-credentials -o json -n ibm-common-services | jq -r '.data."admin_password"' | base64 -D