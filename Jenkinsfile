pipeline {
    agent none
    triggers { cron('H H(0-6) * * 1') }
    environment {
        IMAGE_NAME = 'rstudio-base'
    }
    stages {
        stage('Build Test Deploy') {
            agent {
                kubernetes {
                    cloud 'rke-test'
                    inheritFrom 'podman'
                }
            }
            stages{
                stage('Build') {
                    steps {
                        script {
                            if (currentBuild.getBuildCauses('com.cloudbees.jenkins.GitHubPushCause').size() || currentBuild.getBuildCauses('jenkins.branch.BranchIndexingCause').size()) {
                               scmSkip(deleteBuild: true, skipPattern:'.*\\[ci skip\\].*')
                            }
                        }
                        echo "NODE_NAME = ${env.NODE_NAME}"
                        container('podman') {
                            sh 'podman build -t localhost/$IMAGE_NAME --pull --force-rm --no-cache --from="quay.io/jupyter/r-notebook:latest" .'
                        }
                     }
                    post {
                        unsuccessful {
                            container('podman') {
                                sh 'podman rmi -i localhost/$IMAGE_NAME || true'
                            }
                        }
                    }
                }
                stage('Test') {
                    steps {
                        container('podman') {
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME which rstudio'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME find /usr/share -type f -name lmodern.sty'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -q -e "getRversion() >= \\"4.1.3\\"" | tee /dev/stderr | grep -q "TRUE"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"usethis\");library(\"covr\");library(\"httr\");library(\"roxygen2\");library(\"rversions\");library(\"igraph\");library(\"imager\");library(\"patchwork\");library(\"littler\");library(\"docopt\");library(\"httr\");library(\"WDI\");library(\"faraway\");library(\"boot\");library(\"car\");library(\"pscl\");library(\"vcd\");library(\"stargazer\");library(\"effsize\");library(\"Rmisc\");library(\"tidyverse\");library(\"rstan\");library(\"brms\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME pip install otter-grader'
                            sh 'podman run -d --name=$IMAGE_NAME --rm --pull=never -p 8888:8888 localhost/$IMAGE_NAME start-notebook.sh --NotebookApp.token="jenkinstest"'
                            sh 'sleep 10 && curl -v http://localhost:8888/rstudio?token=jenkinstest 2>&1 | grep -P "HTTP\\S+\\s[1-3][0-9][0-9]\\s+[\\w\\s]+\\s*$"'
                            sh 'curl -v http://localhost:8888/lab?token=jenkinstest 2>&1 | grep -P "HTTP\\S+\\s200\\s+[\\w\\s]+\\s*$"'
                            sh 'curl -v http://localhost:8888/tree?token=jenkinstest 2>&1 | grep -P "HTTP\\S+\\s200\\s+[\\w\\s]+\\s*$"'
                        }
                    }
                    post {
                        always {
                            container('podman') {
                                sh 'podman rm -ifv $IMAGE_NAME'
                            }
                        }
                        unsuccessful {
                            container('podman') {
                                sh 'podman rmi -i localhost/$IMAGE_NAME || true'
                            }
                        }
                    }
                }
                stage('Deploy') {
                    when { branch 'int-test' }
                    environment {
                        DOCKER_HUB_CREDS = credentials('DockerHubToken')
                    }
                    steps {
                        container('podman') {
                            sh 'skopeo copy containers-storage:localhost/$IMAGE_NAME docker://docker.io/ucsb/$IMAGE_NAME:weekly --dest-username $DOCKER_HUB_CREDS_USR --dest-password $DOCKER_HUB_CREDS_PSW'
                        }
                    }
                    post {
                        always {
                            container('podman') {
                                sh 'podman rmi -i localhost/$IMAGE_NAME || true'
                            }
                        }
                    }
                }                
            }
        }
    }
    post {
        success {
            slackSend(channel: '#infrastructure-build', username: 'jenkins', color: 'good', message: "Build ${env.JOB_NAME} ${env.BUILD_NUMBER} just finished successfull! (<${env.BUILD_URL}|Details>)")
        }
        failure {
            slackSend(channel: '#infrastructure-build', username: 'jenkins', color: 'danger', message: "Uh Oh! Build ${env.JOB_NAME} ${env.BUILD_NUMBER} had a failure! (<${env.BUILD_URL}|Find out why>).")
        }
    }
}
