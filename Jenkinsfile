pipeline {
    agent any
    environment {
        IBM_ENTITLEMENT_KEY = credentials('ibm_entitlement_key')
        NAMESPACE           = "mq"
        RELEASE_NAME        = "qm1"
        USE                 = "NonProduction"
        STORAGE_CLASS       = "ibmc-file-gold-gid"
        UPDATE_CERT         = "true"
        LICENSE             = "L-RJON-BZFQU2"
        VERSION             = "9.2.3.0-r1"
    }
    stages {
        stage('Setup') {
            steps {
                echo 'Create namespace, if needed'
                sh('./scripts/00-create-ns.sh ${NAMESPACE}')
                echo 'Add entitlement key as secret'
                sh('./scripts/00-create-ibm-entitlement-key.sh ${IBM_ENTITLEMENT_KEY} ${NAMESPACE}')
                echo 'Setup MQSC'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploy queue manager'
                sh('./scripts/00-deploy-qmgr.sh ${NAMESPACE} ${RELEASE_NAME} ${USE} ${STORAGE_CLASS} ${UPDATE_CERT} ${LICENSE} ${VERSION}')
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
            }
        }
    }
}