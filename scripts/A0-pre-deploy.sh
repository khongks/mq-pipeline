#!/bin/bash

workdir=$(dirname $0)

echo "----------------------------------------------------------------------"
echo " INFO: Pre deploy"
echo "----------------------------------------------------------------------"

ibm_entitlement_key=${1}
name=${2:-qm1}
namespace=${3:-mq}
storage=${4:-ibmc-file-gold-gid} # fyre (using ocs): ocs-storagecluster-cephfs | ibm-cloud: ibmc-file-gold-gid
## https://www.ibm.com/docs/en/ibm-mq/9.2?topic=mqibmcomv1beta1-licensing-reference
## requires ibm-mq-v1.6-ibm-operator-catalog-openshift-marketplace
license=${5:-L-RJON-BZFQU2}
metric=${6:-VirtualProcessorCore}
use=${7:-NonProduction}
version=${8:-9.2.3.0-r1}
availability=${9:-SingleInstance}
channel=${10:-SECUREQMCHL}
new_cert=${11:-false}

# Create namespace
./${workdir}/A1-create-ns.sh ${namespace}

# Create pull secret using ibm entitlement key
./${workdir}/A2-create-ibm-entitlement-key.sh ${namespace} ${ibm_entitlement_key}

# Setup configmap yaml file and queuemanager yaml file
./${workdir}/A3-setup-config-yaml.sh ${name} ${namespace} ${storage} ${license} ${metric} ${use} ${version} ${availability} ${channel}

# Generate new certificates
if [[ new_cert == true ]]; then
    cert_name=${name}cert
    ./${workdir}/A4-generate-tls-cert-and-key.sh ${cert_name}
fi
