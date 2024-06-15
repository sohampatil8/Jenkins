pipeline {
    agent any
    stages {
        stage('Pull') {
            steps {
                git 'https://github.com/soham08022001/studentapp-ui.git'
            }
        }
        stage('Build') {
            steps { 
                 sh '/opt/maven/bin/mvn clean package '
            }
        }
        stage('Test') {
            steps {
                withSonarQubeEnv(credentialsId: 'sonar-creds') {
                sh '/opt/maven/bin/mvn sonar:sonar'
                }
            }
        }
        stage("Quality Gate") {
            steps {
              timeout(time: 1, unit: 'HOURS') {
                waitForQualityGate abortPipeline: true
              }
            }
        }

        stage('Deploy') {
            steps {
                echo '"Deploy successfully"'
            }
        }
    }
}