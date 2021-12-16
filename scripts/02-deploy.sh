#!/bin/bash
#******************************************************************************
# Licensed Materials - Property of IBM
# (c) Copyright IBM Corporation 2020. All Rights Reserved.
#
# Note to U.S. Government Users Restricted Rights:
# Use, duplication or disclosure restricted by GSA ADP Schedule
# Contract with IBM Corp.
#******************************************************************************

## REFER: https://www.ibm.com/docs/en/ibm-mq/9.2?topic=manager-example-configuring-tls
## Testing
# amqssslc -m QM1 -c TLS.SVRCONN -l qm1cert -x 'qm1-ibm-mq-qm-integration.ibmcloud-roks-hybd9-8946bbc006b7c6eb0829d088919818bb-0000.au-syd.containers.appdomain.cloud(443)' -k "./clientkey" -s TLS_RSA_WITH_AES_256_CBC_SHA256
# amqssslc -m QM1 -c TLS.SVRCONN -l qm1cert -x 'secureqmchl.chl.mq.ibm.com(443)' -k "./clientkey" -s TLS_RSA_WITH_AES_256_CBC_SHA256

DIR=`dirname "$0"`
source ${DIR}/functions.sh

echo "----------------------------------------------------------------------"
echo " INFO: Deploy"
echo "----------------------------------------------------------------------"

release_name=${1:-qm1}
namespace=${2:-mq}
storageclass=${3:-ibmc-block-gold} # fyre (using ocs): ocs-storagecluster-cephfs | ibm-cloud: ibmc-file-gold-gid
## https://www.ibm.com/docs/en/ibm-mq/9.2?topic=mqibmcomv1beta1-licensing-reference
## requires ibm-mq-v1.6-ibm-operator-catalog-openshift-marketplace
qmgr_name=${4:-QM1}
channel_name=${5:-QM1CHL}
license=${6:-L-RJON-BZFQU2}
metric=${7:-VirtualProcessorCore}
use=${8:-NonProduction}
version=${9:-9.2.3.0-r1}
availability=${10:-SingleInstance}

## generate mqsc
( echo "cat <<EOF" ; cat ./config/config.mqsc.tmpl ) | \
channel_name=${channel_name} \
sh > ./config/config.mqsc

## indent content in file
sed  's/^/    /'  ./config/config.mqsc > ./config/indented_config.mqsc
sed  's/^/    /'  ./config/qm.ini > ./config/indented_qm.ini

## generate yaml
( echo "cat <<EOF" ; cat ./config/queuemanager.yaml.tmpl ) | \
release_name=${release_name} \
namespace=${namespace} \
storageclass=${storageclass} \
qmgr_name=${qmgr_name} \
channel_name=${channel_name} \
channel_name_lower=$(echo ${channel_name} | tr '[:upper:]' '[:lower:]') \
license=${license} \
metric=${metric} \
use=${use} \
version=${version} \
availability=${availability} \
config_mqsc=$(cat ./config/indented_config.mqsc) \
qm_ini=$(cat ./config/indented_qm.ini) \
server_crt=$(cat certs/mqserver.crt | base64 | tr -d '\n') \
server_key=$(cat certs/mqserver.key | base64 | tr -d '\n') \
client_crt=$(cat certs/mqclient.key | base64 | tr -d '\n') \
sh > ./config/queuemanager.yaml

cat ./config/queuemanager.yaml

## create queuemanager
oc apply -f config/queuemanager.yaml

## wait for queuemanager to be running
wait_for ${release_name} QueueManager ${namespace} "Running"

## display mq console url
mq_console_url=$(oc get queuemanager ${release_name} -n ${namespace} -ojson | jq -r .status.adminUiUrl)
user=$(oc get secret -n ibm-common-services platform-auth-idp-credentials -o json | jq -r '.data.admin_username' | base64 -d)
pass=$(oc get secret -n ibm-common-services platform-auth-idp-credentials -o json | jq -r '.data.admin_password' | base64 -d)

echo "MQ console URL: ${mq_console_url}"
echo "User: ${user}"
echo "Pass: ${pass}"

## generate ccdt.json
host=$(oc get route -n ${namespace} ${release_name}-ibm-mq-qm -ojson | jq -r .spec.host)

( echo "cat <<EOF" ; cat ./config/ccdt.json.tmpl ) | \
channel_name=${channel_name} \
host=${host} \
qmgr_name=${qmgr_name} \
sh > ./client/ccdt.json