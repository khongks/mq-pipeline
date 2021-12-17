#!/bin/bash
#******************************************************************************
# Licensed Materials - Property of IBM
# (c) Copyright IBM Corporation 2020. All Rights Reserved.
#
# Note to U.S. Government Users Restricted Rights:
# Use, duplication or disclosure restricted by GSA ADP Schedule
# Contract with IBM Corp.
#******************************************************************************

DIR=`dirname "$0"`
source ${DIR}/functions.sh

echo "----------------------------------------------------------------------"
echo " INFO: Pre deploy"
echo "----------------------------------------------------------------------"

ibm_entitlement_key=${1}
release_name=${2:-qm1}
namespace=${3:-mq}

create_namespace ${namespace}

secret_name="ibm-entitlement-key"
docker_registry=cp.icr.io
docker_registry_username=cp
docker_registry_password=${ibm_entitlement_key}
docker_registry_user_email="khongks@gmail.com"
create_pull_secret ${secret_name} ${namespace} ${docker_registry} ${docker_registry_username} ${docker_registry_password} ${docker_registry_user_email}

# Setup configmap yaml file and queuemanager yaml file
# ./${workdir}/A3-setup-config-yaml.sh ${name} ${namespace} ${storage} ${license} ${metric} ${use} ${version} ${availability} ${channel}

# Generate new certificates
# if [[ new_cert == true ]]; then
#     server_cert_name=${name}mqserver
#     client_cert_name=${name}mqclient
#     # ./${workdir}/A4-generate-tls-cert-and-key.sh ${cert_name}
#     ./${workdir}/A4-generate-certs.sh ${server_cert_name} ${client_cert_name}
# fi
