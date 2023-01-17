pipeline {
    agent any

    stages {
        stage('terraform') {
            steps {
                sh './terraformw apply -auto-approve -no-color'
            }
        }

/*
        stage('Plan') {
            steps {
              container('terraform') {
                  withCredentials([usernamePassword(credentialsId: 'aws_jenkins_creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                      sh '''
                        terraform plan
                      '''
                    }
                }
            }
        }


        stage('Apply') {
          when {
            branch 'main'
          }
          steps {
            container('terraform') {
                withCredentials([usernamePassword(credentialsId: 'aws_jenkins_creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh '''
                        terraform apply --auto-approve
                    '''
                    }
                }
            }
        }
*/
    }
}
