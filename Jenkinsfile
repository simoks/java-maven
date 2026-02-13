pipeline {
    agent any

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

        stage('Build & Docker') {
            agent {
                docker {
                    image 'my-maven-git:latest'
                    args '-v $WORKSPACE:$WORKSPACE -v maven-repo:/root/.m2 -w $WORKSPACE'
                }
            }
            steps {
                dir('maven') {
                    sh 'mvn clean verify'
                }
                sh "docker build -t $IMAGE_NAME:$IMAGE_TAG ."
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh "docker push $IMAGE_NAME:$IMAGE_TAG"
                }
            }
        }
    }
}
