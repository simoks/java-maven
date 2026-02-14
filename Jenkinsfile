pipeline {
    agent any // Utilise le conteneur Jenkins actuel

    environment {
        IMAGE_NAME = "alpha212/backend"
        IMAGE_TAG  = "${BRANCH_NAME}-${GIT_COMMIT}"
    }

    stages {

        stage('Checkout') {
            steps {
                // Récupérer automatiquement la branche qui déclenche le build
                checkout scm
            }
        }

        stage('Build & Security Scan') {
            steps {
                dir('maven') {
                    echo "Building Maven project"
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

                    // Tag latest uniquement pour main ou release
                    if (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'release') {
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
