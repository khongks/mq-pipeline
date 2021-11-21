#!/bin/bash

echo "----------------------------------------------------------------------"
echo " INFO: Setup config yaml file for queue manager"
echo "----------------------------------------------------------------------"

name=${1:-qm1}
namespace=${2:-mq}
# fyre (using ocs): ocs-storagecluster-cephfs
# ibm-cloud: ibmc-file-gold-gid
storage=${3:-ibmc-file-gold-gid}
## https://www.ibm.com/docs/en/ibm-mq/9.2?topic=mqibmcomv1beta1-licensing-reference
## requires ibm-mq-v1.6-ibm-operator-catalog-openshift-marketplace
license=${4:-L-RJON-BZFQU2}
metric=${5:-VirtualProcessorCore}
use=${6:-NonProduction}
version=${7:-9.2.3.0-r1}
availability=${8:-SingleInstance}
channel=${9:-SECUREQMCHL}
## generated names
cert_name=${name}cert
secret_name=${name}-tls-secret
configmap_name=${name}-configmap
qmgr_name=$(echo ${name} | tr '[:lower:]' '[:upper:]')

( echo "cat <<EOF" ; cat ./config/config.mqsc.tmpl ; ) | \
channel=${channel} \
cert_name=${cert_name} \
sh > ./config/config.mqsc

## indent content in file
sed  's/^/    /'  ./config/config.mqsc > ./config/indented_config.mqsc

## indent content in file
sed  's/^/    /'  ./config/qm.ini > ./config/indented_qm.ini

config_mqsc=$(cat ./config/indented_config.mqsc)
qm_ini=$(cat ./config/indented_qm.ini)

( echo "cat <<EOF" ; cat ./config/configmap.yaml.tmpl ; ) | \
name=${configmap_name} \
namespace=${namespace} \
config_mqsc=${config_mqsc} \
qm_ini=${qm_ini} \
sh > ./config/configmap.yaml

( echo "cat <<EOF" ; cat ./config/queue-manager.yaml.tmpl ; ) | \
name=${name} \
namespace=${namespace} \
storage=${storage} \
license=${license} \
metric=${metric} \
use=${use} \
version=${version} \
availability=${availability} \
qmgr_name=${qmgr_name} \
cert_name=${cert_name} \
secret_name=${secret_name} \
configmap_name=${configmap_name} \
sh > ./config/queue-manager.yaml