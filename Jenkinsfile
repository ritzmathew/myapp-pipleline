pipeline {
    agent {
      kubernetes {
    yaml '''
      apiVersion: v1
      kind: Pod
      metadata:
        labels:
          build: agent
      spec:
        containers:
        - name: terraform
          image: hashicorp/terraform:1.2.0-rc1
          resources:
            requests:
              memory: 100Mi
              cpu: 100m
            limits:
              memory: 300Mi
              cpu: 150m
          command:
          - cat
          tty: true
      '''
      }
  }

  options {
    timestamps()
    timeout(time: 30, unit: 'MINUTES')
  }

    stages {
        stage('Prepare') {
            steps {
              container('terraform') {
                  withCredentials([file(credentialsId: 'gcp-sa-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                      sh '''
                        terraform init
                        terraform validate
                        '''
                      }
                  }
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
