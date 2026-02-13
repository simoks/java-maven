pipeline {
    agent {
        docker {
            image 'my-maven-git:latest'
            // Utiliser un volume Docker pour Maven plutôt que $HOME
            args '-v maven-repo:/root/.m2'
        }
    }
    options {
        // Supprime le workspace automatiquement avant chaque build
        skipDefaultCheckout(false)
    }

    environment {
        IMAGE_NAME = "alpha212/backend"
        IMAGE_TAG  = "commit-${GIT_COMMIT}"
    }

    options {
        // Supprime le workspace automatiquement avant chaque build
        skipDefaultCheckout(false)
    }
    
    stages {

        stage('Checkout') {
            steps {
                // Nettoyer le workspace proprement
                deleteDir()
                
                // Checkout avec les credentials Jenkins configurés
                checkout scm
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
                sh """
                    docker build -t $IMAGE_NAME:$IMAGE_TAG .
                """
            }
        }

        stage('Login Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    '''
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                sh """
                    docker push $IMAGE_NAME:$IMAGE_TAG
                """
            }
        }
    }
}
