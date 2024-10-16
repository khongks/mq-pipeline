pipeline {
    agent any
    environment {
        IBM_ENTITLEMENT_KEY = credentials('ibm_entitlement_key')
        RELEASE_NAME        = "qm1"        
        NAMESPACE           = "mq"
        STORAGE_CLASS       = "ocs-storagecluster-ceph-rbd"
        QMGR_NAME           = "QM1"
        CHANNEL_NAME        = "QM1CHL"
        LICENSE             = "L-RJON-BZFQU2"
        METRIC              = "VirtualProcessorCore"
        USE                 = "NonProduction"
        VERSION             = "9.4.0.5-r2"
        AVAILABILITY        = "SingleInstance"
    }
    stages {
        stage('Pre Deploy') {
            steps {
                echo 'Pre-Deploy ~ setup configuration before deploy'
                sh('./scripts/01-pre-deploy.sh ${IBM_ENTITLEMENT_KEY} ${RELEASE_NAME} ${NAMESPACE}')
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploy ~ deploy queue manager'
                sh('./scripts/02-deploy.sh ${RELEASE_NAME} ${NAMESPACE} ${STORAGE_CLASS} ${QMGR_NAME} ${CHANNEL_NAME} ${LICENSE} ${METRIC} ${USE} ${VERSION} ${AVAILABILITY}')
            }
        }
    }
}
