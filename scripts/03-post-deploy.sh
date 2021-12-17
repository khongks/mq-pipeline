#!/bin/bash

DIR=`dirname "$0"`
source ${DIR}/functions.sh

### Remove temp files
echo "### Remove temp files"

rm ./config/config.mqsc
rm ./config/indented_config.mqsc
rm ./config/indented_qm.ini
rm ./config/queuemanager.yaml