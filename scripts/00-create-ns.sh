#!/bin/bash

namespace=${1:-mq}

# Check if namespace exist
oc get ns ${namespace} 2>&1
if [ "$?" = "0" ]; then
    echo "Namespace ${namespace} found. Do nothing"
else
    echo "Namespace ${namespace} not found. Create ${namespace}"
    oc new-project ${namespace}
fi