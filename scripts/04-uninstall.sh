#!/bin/bash

release_name=${1:-qm1}
namespace=${2:-mq}


echo "Deleting queue manager"
oc delete queuemanager ${release_name} -n ${namespace}

echo "Deleting configmap"
oc delete configmap ${release_name}-cm -n ${namespace}

echo "Deleting TLS secret"
oc delete secret ${release_name}-cert -n ${namespace}

echo "Deleting route"
oc delete route ${release_name}-ibm-mq-qm -n ${namespace}
