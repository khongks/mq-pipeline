#!/bin/bash

name=$1
namespace=$2

echo "----------------------------------------------------------------------"
echo " INFO: Create configmap ${name} in ${namespace}"
echo "----------------------------------------------------------------------"

if [[ -z $name ]]; then
  echo "ERROR: Need to specify param - name"
  exit 1
fi

if [[ -z $namespace ]]; then
  echo "ERROR: Need to specify param - namespace"
  exit 1
fi

oc get configmap -n ${namespace} ${name} -ojson 2>&1
if [ "$?" = "0" ]; then
    echo "Configmap ${name} found. Delete and create ${name}"
    oc delete configmap ${name} -n ${namespace}
else
    echo "Configmap ${name} not found. Create ${name}"
fi

oc apply -f ./config/configmap.yaml