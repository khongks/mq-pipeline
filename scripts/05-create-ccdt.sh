#!/bin/bash

# https://www.ibm.com/docs/en/ibm-mq/9.2?topic=ccdt-json-examples

name=$1
namespace=$2
qmgr_name=$3
ccdt_file=$4
channel=$5

echo "----------------------------------------------------------------------"
echo " INFO: Create CCDT"
echo "----------------------------------------------------------------------"

if [[ -z $name ]]; then
  echo "ERROR: Need to specify param - name"
  exit 1
fi

if [[ -z $qmgr_name ]]; then
  echo "ERROR: Need to specify param - qmgr_name"
  exit 1
fi

if [[ -z $ccdt_file ]]; then
  echo "ERROR: Need to specify param - ccdt_file"
  exit 1
fi

if [[ -z $channel ]]; then
  echo "ERROR: Need to specify param - channel"
  exit 1
fi

# lowercase_channel=$(echo ${channel} | tr '[:upper:]' '[:lower:]')
# hostname="${lowercase_channel}.chl.mq.ibm.com"
hostname=$(oc get route -n ${namespace} ${name}-ibm-mq-qm -ojson | jq -r '.spec.host')

echo "----------------------------------------------------------------------"
echo " INFO: Create CCDT (${channel}): name:${name} hostname:${hostname} qmgr:${qmgr_name} ccdt_file:${ccdt_file}"
echo "----------------------------------------------------------------------"

cat <<EOF > ${ccdt_file}
{
    "channel":
    [
        {
            "name": "${channel}",
            "clientConnection":
            {
                "connection":
                [
                    {
                        "host": "${hostname}",
                        "port": 443
                    }
                ],
                "queueManager": "${qmgr_name}"
            },
            "transmissionSecurity":
            {
              "cipherSpecification": "TLS_RSA_WITH_AES_256_CBC_SHA256"
            },
            "type": "clientConnection"
        }
   ]
}
EOF

echo ${ccdt_file}
cat ${ccdt_file}