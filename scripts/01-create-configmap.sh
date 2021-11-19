#!/bin/bash

name=$1
namespace=$2
cert_name=$3
channel=$4

echo "----------------------------------------------------------------------"
echo " INFO: Create configmap"
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

if [[ -z $channel ]]; then
  echo "ERROR: Need to specify param - channel"
  exit 1
fi

echo "----------------------------------------------------------------------"
echo " INFO: Create configmap ${name} for queue manager"
echo "----------------------------------------------------------------------"

oc get configmap -n ${namespace} ${name} -ojson 2>&1
if [ "$?" = "0" ]; then
    echo "Configmap ${name} found. Delete and create ${name}"
    oc delete configmap ${name} -n ${namespace}
else
    echo "Configmap ${name} not found. Create ${name}"
fi

cat <<EOF | oc apply -f -
kind: ConfigMap
apiVersion: v1
metadata:
  name: ${name}
  namespace: ${namespace}
data:
  config.mqsc: |-
    STOP LISTENER('SYSTEM.DEFAULT.LISTENER.TCP')
  
    * Developer queues
    DEFINE QLOCAL('DEV.QUEUE.1') DEFPSIST(YES)  REPLACE
    DEFINE QLOCAL('DEV.QUEUE.2') DEFPSIST(YES) REPLACE
    DEFINE QLOCAL('DEV.QUEUE.3') DEFPSIST(YES) REPLACE
    DEFINE QLOCAL('DEV.DEAD.LETTER.QUEUE') REPLACE
  
    * Use a different dead letter queue, for undeliverable messages
    ALTER QMGR DEADQ('DEV.DEAD.LETTER.QUEUE')
  
    * Developer topics
    DEFINE TOPIC('DEV.BASE.TOPIC') TOPICSTR('dev/') REPLACE

    * Disable connection authentication
    ALTER QMGR CONNAUTH('')
    REFRESH SECURITY(*) TYPE(CONNAUTH)

    * Developer two channels - one for SSL for external, one for NOSSL for internal
    DEFINE CHL('NOTLS.SVRCONN') CHLTYPE(SVRCONN) MCAUSER('app') REPLACE
    DEFINE CHL('${channel}') CHLTYPE(SVRCONN) MCAUSER('app') REPLACE
    ALTER CHL('${channel}') CHLTYPE(SVRCONN) SSLCIPH(ANY_TLS12_OR_HIGHER) SSLCAUTH(OPTIONAL) CERTLABL('${cert_name}')
    REFRESH SECURITY(*) TYPE(SSL)

    * Developer channel authentication rules
    SET CHLAUTH('NOTLS.SVRCONN') TYPE(BLOCKUSER) USERLIST('nobody') DESCR('Allows anybody on this channel') ACTION(REPLACE)
    SET CHLAUTH('${channel}') TYPE(BLOCKUSER) USERLIST('nobody') DESCR('Allows anybody on this channel') ACTION(REPLACE)

    * Developer TLS
    ALTER QMGR CERTLABL('${cert_name}')

    * Developer listener
    STOP LISTENER('SYSTEM.LISTENER.TCP.1')
    DEFINE LISTENER('DEV.LISTENER.TCP') TRPTYPE(TCP) PORT(1414) CONTROL(QMGR) REPLACE
    START LISTENER('DEV.LISTENER.TCP')
EOF