pipeline {
    agent any
    environment {
        IBM_ENTITLEMENT_KEY = credentials('ibm_entitlement_key')
        NAME                = "qm1"        
        NAMESPACE           = "mq"
        STORAGE_CLASS       = "ibmc-file-gold-gid"
        LICENSE             = "L-RJON-BZFQU2"
        METRIC              = "VirtualProcessorCore"
        USE                 = "NonProduction"
        VERSION             = "9.2.3.0-r1"
        AVAILABILITY        = "SingleInstance"
        CHANNEL             = "SECUREQMCHL"
        NEW_CERT            = "false"
        
    }
    stages {
        stage('Pre-Deploy') {
            steps {
                echo 'Pre-Deploy ~ setup configuration before deploy'
                sh('./scripts/A0-pre-deploy.sh ${IBM_ENTITLEMENT_KEY} ${NAME} ${NAMESPACE} ${STORAGE_CLASS} ${LICENSE} ${METRIC} ${USE} ${VERSION} ${AVAILAIBLITY} ${CHANNEL} $NEW_CERT')
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploy ~ deploy queue manager'
                sh('./scripts/B0-deploy.sh ${NAME} ${NAMESPACE}')
            }
        }
        stage('Post-Deploy') {
            steps {
                echo 'Post-Deploy ~ generate test configuration files'
                sh('./scripts/C0-post-deploy.sh ${NAME} ${NAMESPACE} ${CHANNEL}')
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
            }
        }
    }
}