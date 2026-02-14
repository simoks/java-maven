pipeline {
    agent any // Agent avec Docker installé pour le build/push Docker

    environment {
        IMAGE_NAME = "alpha212/backend"
        IMAGE_TAG  = "${BRANCH_NAME}-${GIT_COMMIT}"
    }

    stages {

        stage('Checkout & Build Maven') {
            agent {
                docker {
                    image 'my-maven-git:latest'
                    args '-v $WORKSPACE:$WORKSPACE -v maven-repo:/root/.m2 -w $WORKSPACE'
                }
            }
            steps {
                checkout scm
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

                    // Tag latest uniquement pour main/release
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
