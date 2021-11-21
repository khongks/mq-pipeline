#!/bin/bash

echo "----------------------------------------------------------------------"
echo " INFO: Create queue manager"
echo "----------------------------------------------------------------------"

oc apply -f config/queue-manager.yaml 