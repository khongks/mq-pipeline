#!/bin/bash

client_folder=$1
ccdt_file=$2
client_kdb_file=$3
cert_name=$4
qmgr_name=$5

# remove suffix
client_key=${client_kdb_file%.*}
echo ${client_key}

if [[ -z $client_folder ]]; then
  echo "ERROR: Need to specify param - client_folder"
  exit 1
fi

if [[ -z $ccdt_file ]]; then
  echo "ERROR: Need to specify param - ccdt_file"
  exit 1
fi

if [[ -z $client_kdb_file ]]; then
  echo "ERROR: Need to specify param - client_kdb_file"
  exit 1
fi

if [[ -z $cert_name ]]; then
  echo "ERROR: Need to specify param - cert_name"
  exit 1
fi

if [[ -z $qmgr_name ]]; then
  echo "ERROR: Need to specify param - qmgr_name"
  exit 1
fi

cat <<EOF > $(dirname $0)/${client_folder}/mq-get.sh
export MQCCDTURL=${ccdt_file}
export MQSSLKEYR=${client_key}
export MQCERTLABL=${cert_name}
# export MQSAMP_USER_ID=app
amqsgetc DEV.QUEUE.3 ${qmgr_name}
EOF

chmod a+x ${client_folder}/mq-get.sh
echo "mq-get.sh"
cat ${client_folder}/mq-get.sh

cat <<EOF > $(dirname $0)/${client_folder}/mq-put.sh
export MQCCDTURL=${ccdt_file}
export MQSSLKEYR=${client_key}
export MQCERTLABL=${cert_name}
# export MQSAMP_USER_ID=app
amqsputc DEV.QUEUE.3 ${qmgr_name}
EOF

chmod a+x $(dirname $0)/${client_folder}/mq-put.sh
echo "mq-put.sh"
cat $(dirname $0)/${client_folder}/mq-put.sh