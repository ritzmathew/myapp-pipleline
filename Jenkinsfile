pipeline {

    environment {
        PROJECT = "my-sample-app-375112"
        APP_NAME = "webgoat"
        CLUSTER = "sample-cluster"
        CLUSTER_ZONE = "us-east1-d"
        IMAGE_TAG = "webgoat/webgoat:${env.BRANCH_NAME}.${env.BUILD_NUMBER}"
        JENKINS_CRED = "${PROJECT}"
    }

    agent {
        kubernetes {
            label 'sample-app'
            defaultContainer 'jnlp'
            yaml """
apiVersion: v1
kind: Pod
metadata:
labels:
  component: ci
spec:
  serviceAccountName: jenkins
  containers:
  - name: dind
    image: docker:18.05-dind
    securityContext:
      privileged: true
    volumeMounts:
      - name: dind-storage
        mountPath: /var/lib/docker
  - name: maven
    image: maven:3.8.3-openjdk-17
    command:
    - sleep
    args:
    - 99d
  - name: kubectl
    image: gcr.io/cloud-builders/kubectl
    command:
    - cat
    tty: true
  volumes:
  - name: dind-storage
    emptyDir: {}
"""
        }
    }

    stages {

        stage('checkout scm and compile') {
            steps {
                git branch: 'main', url: 'https://github.com/WebGoat/WebGoat.git'
                container('maven') {
                    // workaround to unset MAVEN_CONFIG: https://issues.jenkins.io/browse/JENKINS-47890?
                    sh 'unset MAVEN_CONFIG && env && ./mvnw clean package -Dmaven.test.skip'
                }
            }
        }

        stage('docker build and push') {
            steps {
                container('dind') {
                withCredentials([usernamePassword(credentialsId: 'dockerhubcreds', passwordVariable: 'DOCKERHUB_PWD', usernameVariable: 'DOCKERHUB_USR')]) {
                    sh 'docker login -u $DOCKERHUB_USR -p $DOCKERHUB_PWD'
                    sh 'docker build . -t ${IMAGE_TAG}'         
                }
            }
            }
        }
        /*
                stage('terraform') {
                    steps {
                        sh 'terraform apply -auto-approve -no-color'
                    }
                }


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