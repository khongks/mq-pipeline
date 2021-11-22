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

workdir=$(dirname $0)

echo "----------------------------------------------------------------------"
echo " INFO: Deploy"
echo "----------------------------------------------------------------------"

name=${1:-qm1}
namespace=${2:-mq}
channel=${3:-SECUREQMCHL}

cert_name=${name}cert
secret_name=${name}-tls-secret
configmap_name=${name}-configmap
# route_name=${name}-${namespace}-tls-svrconn

${workdir}/B1-create-configmap.sh ${configmap_name} ${namespace}

${workdir}/B2-create-tls-secret.sh ${secret_name} ${namespace} 

${workdir}/B3-create-qmgr.sh

# You don't need to create route, there is a auto-generated route.
# ${workdir}/B4-create-route.sh ${name} ${namespace} ${channel}