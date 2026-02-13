pipeline {
    agent {
        docker {
            image 'my-maven-git:latest'
            args '-v $WORKSPACE:$WORKSPACE -v maven-repo:/root/.m2 -w $WORKSPACE'
        }
    }

    environment {
        IMAGE_NAME = "alpha212/backend"
        IMAGE_TAG  = "commit-${GIT_COMMIT}"
    }

    stages {

        stage('Checkout') {
            steps {
                deleteDir()
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/release']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/simoks/java-maven.git',
                        credentialsId: 'github_token'
                    ]]
                ])
            }
        }

        stage('Build & Security Scan') {
            steps {
                dir('maven') {
                    sh 'mvn clean verify'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t $IMAGE_NAME:$IMAGE_TAG ."
            }
        }

        stage('Login Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                sh "docker push $IMAGE_NAME:$IMAGE_TAG"
            }
        }
    }
}
