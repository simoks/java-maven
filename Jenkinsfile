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
        // Tag basé sur le commit + branch
        IMAGE_TAG  = "${BRANCH_NAME}-${GIT_COMMIT}"
    }

    stages {

        stage('Checkout') {
            steps {
                // Dans Multibranch Pipeline, checkout scm récupère automatiquement la branche qui déclenche
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
                script {
                    // Pousser l'image Docker pour toutes les branches
                    sh "docker push $IMAGE_NAME:$IMAGE_TAG"

                    // Ajouter tag latest uniquement pour main/release
                    if (env.BRANCH_NAME == 'main') {
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
    }
}
