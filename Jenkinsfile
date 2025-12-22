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
    stages {
        stage('Checkout') {
            steps {
                // Nettoyer le workspace proprement
                deleteDir()
                
                // Checkout avec les credentials Jenkins configurés
                checkout scm
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
        /* stage('Dependency-Check') {
            steps {
                dir('maven') { 
                    // Run Maven commands 
                        sh 'mvn org.owasp:dependency-check-maven:check'
                    }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'target/dependency-check-report.html', allowEmptyArchive: true
                }
            }
        }
        */
        stage('Run') {
            steps {
                script {
                    // Exécuter le jar généré
                    dir('maven') { 
                    // Run Maven commands 
                        sh 'java -jar target/maven-0.0.1-SNAPSHOT.jar'
                    }
                }
            }
        }

        stage('Notify Slack'){
            steps {
                script {
                    def artifactPath = "target/maven-0.0.1-SNAPSHOT.jar"
                    def pipelineName = env.JOB_NAME.split('/')[0]
                    def artifactURL = "${env.JENKINS_URL}/job/${pipelineName}/job/main/${env.BUILD_NUMBER}/artifact/${artifactPath}"

                    //Add channel name
                    
                    slackSend channel: 'devops-gr2',
                    message: "Un nouveau build Java est disponible: ---> Resultat: ${currentBuild.currentResult}, Job: ${env.JOB_NAME}, Build: ${env.BUILD_NUMBER} \n <${artifactURL}|Cliquer ici pour télécharger>"
                
                }
            }
        }
    }
}
