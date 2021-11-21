#!/bin/bash

# https://myibm.ibm.com/products-services/containerlibrary

echo "----------------------------------------------------------------------"
echo " INFO: Create entitlement key"
echo "----------------------------------------------------------------------"

entitlementKey=$1
namespace=${2:-mq}

# check for missing mandatory entitlement key
if [ -z "$entitlementKey" ]
then
      echo "ERROR: missing ibm entitlement key argument, make sure to pass a key, ex: '-k mykey'"
      echo "Get key from this https://myibm.ibm.com/products-services/containerlibrary"
      exit 1;
fi

echo '----------------------------------------------------------------------'
echo ' INFO: Create IBM Entitlement Key Secret'
echo '----------------------------------------------------------------------'
# Create IBM Entitlement Key Secret
oc create secret docker-registry ibm-entitlement-key \
    --docker-username=cp \
    --docker-password=$entitlementKey \
    --docker-server=cp.icr.io \
    --namespace=$namespace