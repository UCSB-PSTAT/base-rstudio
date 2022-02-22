pipeline {
    agent none
    environment {
        IMAGE_NAME = 'rstudio-base'
    }
    stages {
        stage('Build Test Deploy') {
            agent {
                label 'jupyter'
            }
            stages{
                stage('Build') {
                    steps {
                        sh 'podman build -t $IMAGE_NAME --pull  --no-cache --from="jupyter/r-notebook:latest" .'
                     }
                }
                stage('Test') {
                    steps {
                        sh 'podman run -it --rm localhost/$IMAGE_NAME which rstudio'
                        sh 'podman run -it --rm localhost/$IMAGE_NAME R -e "library(\"usethis\");library(\"covr\");library(\"httr\");library(\"roxygen2\");library(\"rversions\");library(\"igraph\");library(\"imager\");library(\"patchwork\");library(\"littler\");library(\"docopt\");library(\"httr\");library(\"WDI\");library(\"faraway\");library(\"boot\");library(\"car\");library(\"pscl\");library(\"vcd\");library(\"stargazer\");library(\"effsize\");library(\"Rmisc\");library(\"tidyverse\")"'
                        sh 'podman run -d --name=$IMAGE_NAME --rm -p 8888:8888 localhost/$IMAGE_NAME start-notebook.sh --NotebookApp.token="jenkinstest"'
                        sh 'sleep 10 && curl -v http://localhost:8888/rstudio?token=jenkinstest 2>&1 | grep -P "HTTP\\S+\\s[1-3][0-9][0-9]\\s+[\\w\\s]+\\s*$"'
                        sh 'curl -v http://localhost:8888/lab?token=jenkinstest 2>&1 | grep -P "HTTP\\S+\\s200\\s+[\\w\\s]+\\s*$"'
                        sh 'curl -v http://localhost:8888/tree?token=jenkinstest 2>&1 | grep -P "HTTP\\S+\\s200\\s+[\\w\\s]+\\s*$"'
                    }
                    post {
                        always {
                            sh 'podman rm -ifv $IMAGE_NAME'
                        }
                    }
                }
                stage('Deploy') {
                    when { branch 'int-test' }
                    environment {
                        DOCKER_HUB_CREDS = credentials('DockerHubToken')
                    }
                    steps {
                        sh 'skopeo copy containers-storage:localhost/$IMAGE_NAME docker://docker.io/ucsb/$IMAGE_NAME:weekly --dest-username $DOCKER_HUB_CREDS_USR --dest-password $DOCKER_HUB_CREDS_PSW'
                    }
                }                
            }
        }
    }
    post {
        success {
            slackSend(channel: '#infrastructure-build', username: 'jenkins', message: "Build ${env.JOB_NAME} ${env.BUILD_NUMBER} just finished successfull! (<${env.BUILD_URL}|Details>)")
        }
        failure {
            slackSend(channel: '#infrastructure-build', username: 'jenkins', message: "Uh Oh! Build ${env.JOB_NAME} ${env.BUILD_NUMBER} had a failure! (<${env.BUILD_URL}|Find out why>).")
        }
    }
}
