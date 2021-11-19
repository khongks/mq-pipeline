#!/bin/bash

name=$1
namespace=$2
cert_name=$3
secret_name=$4
configmap_name=$5
license=$6
use=$7
version=$8
storage=$9

qmgr_name=$(echo ${name} | tr '[:lower:]' '[:upper:]')

echo "----------------------------------------------------------------------"
echo " INFO: Create queue manager"
echo "----------------------------------------------------------------------"

if [[ -z $name ]]; then
  echo "ERROR: Need to specify param - name"
  exit 1
fi

if [[ -z $namespace ]]; then
  echo "ERROR: Need to specify param - namespace"
  exit 1
fi

if [[ -z $cert_name ]]; then
  echo "ERROR: Need to specify param - cert_name"
  exit 1
fi

if [[ -z $secret_name ]]; then
  echo "ERROR: Need to specify param - secret_name"
  exit 1
fi

if [[ -z $configmap_name ]]; then
  echo "ERROR: Need to specify param - configmap_name"
  exit 1
fi

if [[ -z $license ]]; then
  echo "ERROR: Need to specify param - license"
  exit 1
fi

if [[ -z $use ]]; then
  echo "ERROR: Need to specify param - use"
  exit 1
fi

if [[ -z $version ]]; then
  echo "ERROR: Need to specify param - version"
  exit 1
fi

if [[ -z $storage ]]; then
  echo "ERROR: Need to specify param - storage"
  exit 1
fi

echo "----------------------------------------------------------------------"
echo " INFO: Create queue manager name: ${name} ns: ${namespace}"
echo " cert_name: ${cert_name}, secret_name: ${secret_name}"
echo "----------------------------------------------------------------------"

cat <<EOF | oc apply -f -
apiVersion: mq.ibm.com/v1beta1
kind: QueueManager
metadata:
  name: ${name}
  namespace: ${namespace}
spec:
  license:
    accept: true
    license: ${license}
    metric: VirtualProcessorCore
    use: ${use}
  pki:
    keys:
      - name: ${cert_name}
        secret:
          items:
            - tls.key
            - tls.crt
          secretName: ${secret_name}
  queueManager:
    name: ${qmgr_name}
    mqsc:
      - configMap:
          items:
            - config.mqsc
          name: ${configmap_name}
    storage:
      accessModes:
        - ReadWriteMany
      mountOptions:
        - dir_mode=0755
        - file_mode=0755
      defaultClass: ${storage}
      defaultDeleteClaim: true
      persistedData:
        class: ${storage}
        deleteClaim: true
        enabled: true
        type: persistent-claim
      queueManager:
        class: ${storage}
        deleteClaim: true
        type: persistent-claim
      recoveryLogs:
        class: ${storage}
        deleteClaim: true
        enabled: true
        type: persistent-claim
    resources:
      limits:
        cpu: 1
        memory: 1Gi
      requests:
        cpu: 500m
        memory: 50Mi
    availability:
      type: SingleInstance
  template:
    pod:
      containers:
        - env:
            - name: MQSNOAUT
              value: 'yes'
          name: qmgr
  version: ${version}
  web:
    enabled: true
  securityContext:
     supplementalGroups: [99]
EOF