pipeline {

    environment {
        PROJECT = "my-sample-app-375112"
        APP_NAME = "lfkwebapp"
        SVC_NAME = "lfkwebapp-service"
        CLUSTER = "my-sample-app-375112-cluster"
        CLUSTER_LOCATION = "us-east1"
        IMAGE_TAG = "ritzmathew/lfkwebapp:${env.BRANCH_NAME}.${env.BUILD_NUMBER}"
        JENKINS_CRED = "${PROJECT}"
    }

    agent {
        kubernetes {
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
  volumes:
  - name: dind-storage
    emptyDir: {}
"""
        }
    }

    stages {
        
        stage('checkout scm and build') {
            steps {
                git branch: 'main', url: 'https://github.com/ritzmathew/LittleFlowerKalewadi.git', credentialsId: 'githubcreds'
                container('dind') {
                sh 'docker build . -t ${IMAGE_TAG}'
              }
            }
        }

        stage('docker push') {
            steps {
              container('dind') {
                withCredentials([usernamePassword(credentialsId: 'dockerhubcreds', passwordVariable: 'DOCKERHUB_PWD', usernameVariable: 'DOCKERHUB_USR')]) {
                    sh 'docker login -u $DOCKERHUB_USR -p $DOCKERHUB_PWD'
                    sh 'docker push ${IMAGE_TAG}'         
                }
              }
            }
        }

        stage('terraform init') {
          steps {
            container('terraform') {
              checkout scm
              withCredentials([string(credentialsId: 'jenkins-sa-token', variable: 'JENKINS_SA_TOKEN')]) {
                sh "export GOOGLE_APPLICATION_CREDENTIALS='${JENKINS_SA_TOKEN}'"
                sh 'terraform init'
              }
            }
          }
        }

        stage('terraform apply') {
          steps {
            container('terraform') {
              checkout scm
              withCredentials([string(credentialsId: 'jenkins-sa-token', variable: 'JENKINS_SA_TOKEN')]) {
                sh "export GOOGLE_APPLICATION_CREDENTIALS='${JENKINS_SA_TOKEN}'"
                sh 'terraform apply -auto-approve -no-color'
              }
            }
          }
        }

        stage('Deploy Canary') {
          when { branch 'canary' }
          steps {
            container('kubectl') {
              sh("sed -i.bak 's#ritzmathew/lfkwebapp:canary#${IMAGE_TAG}#' ./k8s/canary/*.yaml")
              step([$class: 'KubernetesEngineBuilder', namespace:'production', projectId: env.PROJECT, clusterName: env.CLUSTER, location: env.CLUSTER_LOCATION, manifestPattern: 'k8s/services', credentialsId: env.JENKINS_CRED, verifyDeployments: false])
              step([$class: 'KubernetesEngineBuilder', namespace:'production', projectId: env.PROJECT, clusterName: env.CLUSTER, location: env.CLUSTER_LOCATION, manifestPattern: 'k8s/canary', credentialsId: env.JENKINS_CRED, verifyDeployments: true])
            }
          }
        }

        stage('Deploy Production') {
          when { 
            anyOf { 
              branch 'main' 
              branch 'master' 
            }
          }
          steps {
            container('kubectl') {
              sh("sed -i.bak 's#ritzmathew/lfkwebapp:prod#${IMAGE_TAG}#' ./k8s/prod/*.yaml")
              step([$class: 'KubernetesEngineBuilder', namespace:'production', projectId: env.PROJECT, clusterName: env.CLUSTER, location: env.CLUSTER_LOCATION, manifestPattern: 'k8s/services', credentialsId: env.JENKINS_CRED, verifyDeployments: false])
              step([$class: 'KubernetesEngineBuilder', namespace:'production', projectId: env.PROJECT, clusterName: env.CLUSTER, location: env.CLUSTER_LOCATION, manifestPattern: 'k8s/prod', credentialsId: env.JENKINS_CRED, verifyDeployments: true])
            }
          }
        }

        stage('Deploy Dev') {
          when {
            not { branch 'main' }
            not { branch 'master' }
            not { branch 'canary' }
          }
          steps {
            container('kubectl') {
              sh("sed -i.bak 's#ritzmathew/lfkwebapp:dev#${IMAGE_TAG}#' ./k8s/dev/*.yaml")
              step([$class: 'KubernetesEngineBuilder', namespace:'development', projectId: env.PROJECT, clusterName: env.CLUSTER, location: env.CLUSTER_LOCATION, manifestPattern: 'k8s/services', credentialsId: env.JENKINS_CRED, verifyDeployments: false])
              step([$class: 'KubernetesEngineBuilder', namespace:'development', projectId: env.PROJECT, clusterName: env.CLUSTER, location: env.CLUSTER_LOCATION, manifestPattern: 'k8s/dev', credentialsId: env.JENKINS_CRED, verifyDeployments: true])
            }
          }
        }
    }
}