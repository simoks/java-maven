pipeline {
    agent any // Agent Jenkins avec Docker installé pour Docker build/push

    environment {
        IMAGE_NAME = "alpha212/backend"
        IMAGE_TAG  = "${BRANCH_NAME}-${GIT_COMMIT}"
    }

    stages {

        stage('Checkout') {
            steps {
                echo "Checking out branch ${BRANCH_NAME}"
                checkout scm
            }
        }

        stage('Build & Security Scan') {
            agent {
                docker {
                    image 'my-maven-git:latest'
                    args '-v $WORKSPACE:$WORKSPACE -v maven-repo:/root/.m2 -w $WORKSPACE'
                }
            }
            steps {
                dir('maven') {
                    echo "Building Maven project and running OWASP dependency-check"
                    sh 'mvn clean verify'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image $IMAGE_NAME:$IMAGE_TAG"
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
                    echo "Logging in to Docker Hub"
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    echo "Pushing Docker image $IMAGE_NAME:$IMAGE_TAG"
                    sh "docker push $IMAGE_NAME:$IMAGE_TAG"

                    // Ajouter tag latest uniquement pour main ou release
                    if (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'release') {
                        echo "Tagging $IMAGE_NAME:latest for branch ${BRANCH_NAME}"
                        sh "docker tag $IMAGE_NAME:$IMAGE_TAG $IMAGE_NAME:latest"
                        sh "docker push $IMAGE_NAME:latest"
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning workspace..."
            deleteDir()
        }
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}
