pipeline {
    agent any

    stages {
        stage('Setup') {
            steps {
                echo 'Setup MQSC'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploy queue manager'
                ./scripts/00-deploy-qmgr.sh
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
            }
        }
    }
}