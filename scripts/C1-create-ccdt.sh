#!/bin/bash

# https://www.ibm.com/docs/en/ibm-mq/9.2?topic=ccdt-json-examples

name=$1
namespace=$2
channel=$3
ccdt_file=$4

cert_name=${name}cert
qmgr_name=$(echo ${name} | tr '[:lower:]' '[:upper:]')

echo "----------------------------------------------------------------------"
echo " INFO: Create CCDT"
echo "----------------------------------------------------------------------"

if [[ -z $qmgr_name ]]; then
  echo "ERROR: Need to specify param - qmgr_name"
  exit 1
fi
if [[ -z $channel ]]; then
  echo "ERROR: Need to specify param - channel"
  exit 1
fi
if [[ -z $cert_name ]]; then
  echo "ERROR: Need to specify param - cert_name"
  exit 1
fi
if [[ -z $ccdt_file ]]; then
  echo "ERROR: Need to specify param - ccdt_file"
  exit 1
fi

hostname=$(oc get route -n ${namespace} ${name}-ibm-mq-qm -ojson | jq -r '.spec.host')

( echo "cat <<EOF" ; cat ./config/${ccdt_file}.tmpl ; ) | \
qmgr_name=${qmgr_name} \
hostname=${hostname} \
channel=${channel} \
cert_name=${cert_name} \
sh > ./client/${ccdt_file}

cat ./client/${ccdt_file}