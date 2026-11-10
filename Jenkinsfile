pipeline {
    agent {
        docker {
            image 'my-maven-git:latest'
            // Utiliser un volume Docker pour Maven plutôt que $HOME
            args '-v maven-repo:/root/.m2'
            reuseNode true
        }
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
                //checkout scm
                git url: 'https://github.com/simoks/java-maven.git', branch: 'emsi'
            }
        }
        
        stage('Debug Git') {
            steps {
                sh 'pwd'
                sh 'ls -la'
                sh 'git status || echo "NO GIT REPO"'
            }
        }
        stage('Build & Test') {
            steps {
                script {
                    echo "Current directory: ${pwd()}"
                    
                    // Navigate to the directory containing the Maven project 
                    dir('maven') { 
                    // Run Maven commands 
                        sh 'mvn clean test package'
                        archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
                    }
                }
            }
        }
        
        stage('Run') {
            steps {
                script {
                    // Exécuter le jar généré
                    dir('maven') { 
                    // Run Maven commands 
                        sh 'java -jar target/maven-1.1.1-SNAPSHOT.jar'
                    }
                }
            }
        }
    }
}
