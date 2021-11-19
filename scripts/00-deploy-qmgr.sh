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

function usage() {
  echo "Usage: $0 <namespace> <release_name> <use>(NonProduction|Production) <storage> <license> <version>"
  echo "E.g.: $0 integration qm1 nonproduction ibmc-block-gold"
}
namespace=${1:-integration}
release_name=${2:-qm1}
use=${3:-NonProduction}
# fyre (using ocs): ocs-storagecluster-cephfs
# ibm-cloud: ibmc-file-gold-gid
storage=${4:-ibmc-file-gold-gid}
## https://www.ibm.com/docs/en/ibm-mq/9.2?topic=mqibmcomv1beta1-licensing-reference
## requires ibm-mq-v1.6-ibm-operator-catalog-openshift-marketplace
license=${5:-L-RJON-BZFQU2}
version=${6:-9.2.3.0-r1}
update_cert=${7:-false}
channel="SECUREQMCHL"

cert_name=${release_name}cert
secret_name=${release_name}-tls-secret
configmap_name=${release_name}-configmap
# route_name=${release_name}-${namespace}-tls-svrconn
# qmgr_name=${name^^}
qmgr_name=$(echo ${release_name} | tr '[:lower:]' '[:upper:]')
client_folder="client"
ccdt_file="ccdt.json"
client_kdb_file="clientkey.kdb"

if [[ -d ${client_folder} ]]; then
  mkdir -p ${client_folder}
fi

echo "INFO: Install MQ $release_name in $namespace, $release_name as $use using $storage"

$(dirname $0)/01-create-configmap.sh ${configmap_name} ${namespace} ${cert_name} ${channel}

# Mask this if you don't want to re-generate certs.
# If you re-generate certs, you need to restart the pods.
if [[ ${update_cert} == true ]]; then
  $(dirname $0)/02-create-tls-secret.sh ${cert_name} ${namespace} ${secret_name} ${client_folder} ${client_kdb_file}
fi

# name=$1
# namespace=$2
# cert_name=$3
# secret_name=$4
# configmap_name=$5
# license=$6
# use=$7
# version=$8
# storage=$9
$(dirname $0)/03-create-qmgr.sh ${release_name} ${namespace} ${cert_name} ${secret_name} ${configmap_name} ${license} ${use} ${version} ${storage}

# You don't need to create route, there is a auto-generated route.
# $(dirname $0)/04-create-route.sh ${release_name} ${namespace} ${qmgr_name} ${channel}

$(dirname $0)/05-create-ccdt.sh ${release_name} ${qmgr_name} ${client_folder}/${ccdt_file} ${channel}

# client_folder=$1
# ccdt_file=$2
# client_kdb_file=$3
# cert_name=$4
# qmgr_name=$5
$(dirname $0)/07-create-client-script.sh ${client_folder} ${ccdt_file} ${client_kdb_file} ${cert_name} ${qmgr_name}
