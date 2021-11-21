#!/bin/bash

name=$1
namespace=$2
channel=$3

qmgr_name=$(echo ${name} | tr '[:lower:]' '[:upper:]')
route_name=${name}-route

lowercase_channel=$(echo ${channel} | tr '[:upper:]' '[:lower:]')
host="${lowercase_channel}.chl.mq.ibm.com"

echo "----------------------------------------------------------------------"
echo " INFO: Create route"
echo "----------------------------------------------------------------------"

if [[ -z $name ]]; then
  echo "ERROR: Need to specify param - name"
  exit 1
fi

if [[ -z $namespace ]]; then
  echo "ERROR: Need to specify param - namespace"
  exit 1
fi

if [[ -z $channel ]]; then
  echo "ERROR: Need to specify param - channel "
  exit 1
fi

cat << EOF | oc apply -f -
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: ${route_name}
  namespace: ${namespace}
spec:
  host: ${host}
  to:
    kind: Service
    name: ${name}-${channel}
  port:
    targetPort: 1414
  tls:
    termination: passthrough
EOF