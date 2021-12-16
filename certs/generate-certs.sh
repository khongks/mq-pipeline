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

SERVER_KEY=mqserver.key
SERVER_CRT=mqserver.crt
SERVER_KDB=mqserver.kdb
SERVER_P12=mqserver.p12
SERVER_CRT_NAME=${1:-mqserver}
CLIENT_KEY=mqclient.key
CLIENT_CRT=mqclient.crt
CLIENT_KDB=mqclient.kdb
CLIENT_P12=mqclient.p12
CLIENT_CRT_NAME=${2:-mqclient}
PASSWORD=passw0rd

# Create a private key and certificate in PEM format, for the server to use
echo "#####################################################################################"
echo "#### Create a private key and certificate in PEM format, for the queue manager to use"
echo "#####################################################################################"
openssl req \
       -newkey rsa:2048 -nodes -keyout ${SERVER_KEY} \
       -subj "/CN=${SERVER_CRT_NAME}" \
       -x509 -days 3650 -out ${SERVER_CRT}

openssl pkcs12 -export -out ${SERVER_P12} -inkey ${SERVER_KEY} -in ${SERVER_CRT} -passout pass:${PASSWORD}

# Create a private key and certificate in PEM format, for the mq client to use
echo "#####################################################################################"
echo "#### Create a private key and certificate in PEM format, for the mq client to use"
echo "#####################################################################################"
openssl req \
       -newkey rsa:2048 -nodes -keyout ${CLIENT_KEY} \
       -subj "/CN=${CLIENT_CRT_NAME}" \
       -x509 -days 3650 -out ${CLIENT_CRT}

openssl pkcs12 -export -out ${CLIENT_P12} -inkey ${CLIENT_KEY} -in ${CLIENT_CRT} -passout pass:${PASSWORD}

# Add the key and certificate to a kdb key store, for the queue manager to use
echo "#####################################################################################"
echo "#### Creating kdb key store, for the queue manager to use"
echo "#####################################################################################"
runmqakm -keydb -create -db ${SERVER_KDB} -pw ${PASSWORD} -type cms -stash
echo "#####################################################################################"
echo "#### Adding certs and keys to kdb key store, for the queue manager to use"
echo "#####################################################################################"
runmqakm -cert -add -db ${SERVER_KDB} -file ${CLIENT_CRT} -stashed -label ${CLIENT_CRT_NAME}
runmqakm -cert -import -file ${SERVER_P12} -pw ${PASSWORD} -target ${SERVER_KDB} -target_stashed -new_label ${SERVER_CRT_NAME}
runmqakm -cert -setdefault -db ${SERVER_KDB} -type cms -stashed -label ${SERVER_CRT_NAME}
runmqakm -cert -details -db ${SERVER_KDB} -type cms -stashed -label ${SERVER_CRT_NAME}

# Add the key and certificate to a kdb key store, for the mq client to use
echo "#####################################################################################"
echo "#### Add the key and certificate to a kdb key store, for the mq client to use"
echo "#####################################################################################"
runmqakm -keydb -create -db ${CLIENT_KDB} -pw ${PASSWORD} -type cms -stash
echo "#####################################################################################"
echo "#### Adding certs and keys to kdb key store, for the mq client to use"
echo "#####################################################################################"
runmqakm -cert -add -db ${CLIENT_KDB} -file ${SERVER_CRT} -stashed -label ${SERVER_CRT_NAME}
runmqakm -cert -import -file ${CLIENT_P12} -pw ${PASSWORD} -target ${CLIENT_KDB} -target_stashed -new_label ${CLIENT_CRT_NAME}
runmqakm -cert -setdefault -db ${CLIENT_KDB} -type cms -stashed -label ${CLIENT_CRT_NAME}
runmqakm -cert -details -db ${CLIENT_KDB} -type cms -stashed -label ${CLIENT_CRT_NAME}

echo "#####################################################################################"
echo "#### Listing ${SERVER_KDB}"
echo "#####################################################################################"
runmqakm -cert -list -db ${SERVER_KDB} -type cms -stashed

#echo "#### Details of ${SERVER_KDB}"
# runmqakm -cert -details -db ${SERVER_KDB} -type cms -stashed -label ${SERVER_CRT_NAME}

echo "#####################################################################################"
echo "#### Listing ${CLIENT_KDB}"
echo "#####################################################################################"
runmqakm -cert -list -db ${CLIENT_KDB} -type cms -stashed

#echo "#### Details of ${CLIENT_KDB}"
# runmqakm -cert -details -db ${CLIENT_KDB} -type cms -stashed -label ${CLIENT_CRT_NAME}
