pipeline {
    agent any
    stages {
        stage('Setup') {
            steps {
                echo 'Create namespace, if needed'
                sh('./scripts/00-create-ns.sh mq')
                echo 'Setup MQSC'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploy queue manager'
                sh('./scripts/00-deploy-qmgr.sh mq qm1 NonProduction ibmc-file-gold-gid true')
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
            }
        }
    }
}