pipeline {

    environment {
        PROJECT = "my-sample-app-375112"
        APP_NAME = "sampleapp"
        SVC_NAME = "sampleapp-service"
        CLUSTER = "my-sample-app-375112-cluster"
        CLUSTER_LOCATION = "us-east1"
        IMAGE_TAG = "ritzmathew/sampleapp:${env.BRANCH_NAME}.${env.BUILD_NUMBER}"
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
        
        stage('docker build') {
            steps {
                container('dind') {
                  sh("sed -i.bak 's#Version: 1.0#Version:1.0.${env.BUILD_NUMBER}-${env.BRANCH_NAME}#' ./sampleapp/index.html")
                  sh 'docker build ./sampleapp -t ${IMAGE_TAG}'
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

        stage('deploy Canary') {
          when { branch 'canary' }
          steps {
            container('kubectl') {
              sh("sed -i.bak 's#ritzmathew/sampleapp:canary#${IMAGE_TAG}#' ./k8s/canary/*.yaml")
              step([$class: 'KubernetesEngineBuilder', namespace:'production', projectId: env.PROJECT, clusterName: env.CLUSTER, location: env.CLUSTER_LOCATION, manifestPattern: 'k8s/services', credentialsId: env.JENKINS_CRED, verifyDeployments: false])
              step([$class: 'KubernetesEngineBuilder', namespace:'production', projectId: env.PROJECT, clusterName: env.CLUSTER, location: env.CLUSTER_LOCATION, manifestPattern: 'k8s/canary', credentialsId: env.JENKINS_CRED, verifyDeployments: true])
            }
          }
        }

        stage('deploy Production') {
          when { 
            anyOf { 
              branch 'main' 
              branch 'master' 
            }
          }
          steps {
            container('kubectl') {
              sh("sed -i.bak 's#ritzmathew/sampleapp:prod#${IMAGE_TAG}#' ./k8s/prod/*.yaml")
              step([$class: 'KubernetesEngineBuilder', namespace:'production', projectId: env.PROJECT, clusterName: env.CLUSTER, location: env.CLUSTER_LOCATION, manifestPattern: 'k8s/services', credentialsId: env.JENKINS_CRED, verifyDeployments: false])
              step([$class: 'KubernetesEngineBuilder', namespace:'production', projectId: env.PROJECT, clusterName: env.CLUSTER, location: env.CLUSTER_LOCATION, manifestPattern: 'k8s/prod', credentialsId: env.JENKINS_CRED, verifyDeployments: true])
            }
          }
        }

        stage('deploy Development') {
          when {
            not { branch 'main' }
            not { branch 'master' }
            not { branch 'canary' }
          }
          steps {
            container('kubectl') {
              sh("sed -i.bak 's#ritzmathew/sampleapp:dev#${IMAGE_TAG}#' ./k8s/dev/*.yaml")
              step([$class: 'KubernetesEngineBuilder', namespace:'development', projectId: env.PROJECT, clusterName: env.CLUSTER, location: env.CLUSTER_LOCATION, manifestPattern: 'k8s/services', credentialsId: env.JENKINS_CRED, verifyDeployments: false])
              step([$class: 'KubernetesEngineBuilder', namespace:'development', projectId: env.PROJECT, clusterName: env.CLUSTER, location: env.CLUSTER_LOCATION, manifestPattern: 'k8s/dev', credentialsId: env.JENKINS_CRED, verifyDeployments: true])
            }
          }
        }

        stage('deploy Staging') {
          when { branch 'stag' }
          steps {
            container('kubectl') {
              sh("sed -i.bak 's#ritzmathew/sampleapp:stag#${IMAGE_TAG}#' ./k8s/stag/*.yaml")
              step([$class: 'KubernetesEngineBuilder', namespace:'staging', projectId: env.PROJECT, clusterName: env.CLUSTER, location: env.CLUSTER_LOCATION, manifestPattern: 'k8s/services', credentialsId: env.JENKINS_CRED, verifyDeployments: false])
              step([$class: 'KubernetesEngineBuilder', namespace:'staging', projectId: env.PROJECT, clusterName: env.CLUSTER, location: env.CLUSTER_LOCATION, manifestPattern: 'k8s/stag', credentialsId: env.JENKINS_CRED, verifyDeployments: true])
            }
          }
        }
    }
}