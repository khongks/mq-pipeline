#!/bin/bash
# -*- mode: sh -*-
# © Copyright IBM Corporation 2018
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

SECRET_NAME=$1
NAMESPACE=$2
CERT_FOLDER=certs
CLIENT_FOLDER=client
SERVER_KEY=mqserver.key
SERVER_CRT=mqserver.crt
SERVER_KDB=mqserver.kdb
SERVER_P12=mqserver.p12
SERVER_CRT_NAME=${3:-mqserver}
CLIENT_KEY=mqclient.key
CLIENT_CRT=mqclient.crt
CLIENT_KDB=mqclient.kdb
CLIENT_P12=mqclient.p12
CLIENT_CRT_NAME=${4:-mqclient}
PASSWORD=passw0rd

# Create a private key and certificate in PEM format, for the server to use
echo "#### Create a private key and certificate in PEM format, for the queue manager to use"
openssl req \
       -newkey rsa:2048 -nodes -keyout ${CERT_FOLDER}/${SERVER_KEY} \
       -subj "/CN=${SERVER_CRT_NAME}" \
       -x509 -days 3650 -out ${CERT_FOLDER}/${SERVER_CRT}

openssl pkcs12 -export -out ${CERT_FOLDER}/${SERVER_P12} -inkey ${CERT_FOLDER}/${SERVER_KEY} -in ${CERT_FOLDER}/${SERVER_CRT} -passout pass:${PASSWORD}

# Create a private key and certificate in PEM format, for the mq client to use
echo "#### Create a private key and certificate in PEM format, for the mq client to use"
openssl req \
       -newkey rsa:2048 -nodes -keyout ${CERT_FOLDER}/${CLIENT_KEY} \
       -subj "/CN=${CLIENT_CRT_NAME}" \
       -x509 -days 3650 -out ${CERT_FOLDER}/${CLIENT_CRT}

openssl pkcs12 -export -out ${CERT_FOLDER}/${CLIENT_P12} -inkey ${CERT_FOLDER}/${CLIENT_KEY} -in ${CERT_FOLDER}/${CLIENT_CRT} -passout pass:${PASSWORD}

# Add the key and certificate to a kdb key store, for the queue manager to use
echo "#### Creating kdb key store, for the queue manager to use"
runmqakm -keydb -create -db ${CLIENT_FOLDER}/${SERVER_KDB} -pw ${PASSWORD} -type cms -stash
echo "#### Adding certs and keys to kdb key store, for the queue manager to use"
runmqakm -cert -add -db ${CLIENT_FOLDER}/${SERVER_KDB} -file ${CERT_FOLDER}/${CLIENT_CRT} -stashed -label ${CLIENT_CRT_NAME}
runmqakm -cert -import -file ${CERT_FOLDER}/${SERVER_P12} -pw ${PASSWORD} -target ${CLIENT_FOLDER}/${SERVER_KDB} -target_stashed -new_label ${SERVER_CRT_NAME}
runmqakm -cert -setdefault -db ${CLIENT_FOLDER}/${SERVER_KDB} -type cms -stashed -label ${SERVER_CRT_NAME}
runmqakm -cert -details -db ${CLIENT_FOLDER}/${SERVER_KDB} -type cms -stashed -label ${SERVER_CRT_NAME}

# Add the key and certificate to a kdb key store, for the mq client to use
echo "#### Add the key and certificate to a kdb key store, for the mq client to use"
runmqakm -keydb -create -db ${CLIENT_FOLDER}/${CLIENT_KDB} -pw ${PASSWORD} -type cms -stash
echo "#### Adding certs and keys to kdb key store, for the mq client to use"
runmqakm -cert -add -db ${CLIENT_FOLDER}/${CLIENT_KDB} -file ${CERT_FOLDER}/${SERVER_CRT} -stashed -label ${SERVER_CRT_NAME}
runmqakm -cert -import -file ${CERT_FOLDER}/${CLIENT_P12} -pw ${PASSWORD} -target ${CLIENT_FOLDER}/${CLIENT_KDB} -target_stashed -new_label ${CLIENT_CRT_NAME}
runmqakm -cert -setdefault -db ${CLIENT_FOLDER}/${CLIENT_KDB} -type cms -stashed -label ${CLIENT_CRT_NAME}
runmqakm -cert -details -db ${CLIENT_FOLDER}/${CLIENT_KDB} -type cms -stashed -label ${CLIENT_CRT_NAME}

echo "#### Listing ${CLIENT_FOLDER}/${SERVER_KDB}"
runmqakm -cert -list -db ${CLIENT_FOLDER}/${SERVER_KDB} -type cms -stashed

#echo "#### Details of ${CLIENT_FOLDER}/${SERVER_KDB}"
# runmqakm -cert -details -db ${CLIENT_FOLDER}/${SERVER_KDB} -type cms -stashed -label ${SERVER_CRT_NAME}

echo "#### Listing ${CLIENT_FOLDER}/${CLIENT_KDB}"
runmqakm -cert -list -db ${CLIENT_FOLDER}/${CLIENT_KDB} -type cms -stashed

#echo "#### Details of ${CLIENT_FOLDER}/${CLIENT_KDB}"
# runmqakm -cert -details -db ${CLIENT_FOLDER}/${CLIENT_KDB} -type cms -stashed -label ${CLIENT_CRT_NAME}

( echo "cat <<EOF" ; cat ./config/tls-secret.yaml.tmpl ; ) | \
secret_name=${SECRET_NAME} \
namespace=${NAMESPACE} \
server_key=$(cat ${CERT_FOLDER}/${SERVER_KEY} | base64 | tr -d '\n') \
server_crt=$(cat ${CERT_FOLDER}/${SERVER_CRT} | base64 | tr -d '\n') \
client_crt=$(cat ${CERT_FOLDER}/${CLIENT_CRT} | base64 | tr -d '\n') \
sh > ./config/tls-secret.yaml