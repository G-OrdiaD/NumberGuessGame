// Jenkins Pipeline for building, testing, and deploying a Java web application to Tomcat
pipeline {
  agent any
    // Define global options for the pipeline
  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '20'))
    ansiColor('xterm')
  }
    // Define the tools required for the build
  tools {
    jdk 'Java_11' // Java version make sure to configure in Jenkins global tools
    maven 'Maven_3.8.4' // Maven version make sure to configure in Jenkins global tools
  }
    // Define environment variables
  environment {
    APP_NAME = "NumberGuessGame-1.0-SNAPSHOT" // war name without .war
    TOMCAT_WEBAPPS = "/opt/tomcat/webapps"   // tomcat webapps dir
    DEPLOY_MODE = "local"                    // Local deployment
  }

    // Define the stages of the pipeline
  stages {
    // Checkout the code from SCM
    stage('01 – Checkout Code') {
      steps {
        checkout scm
      }
    }
    // Build the application using Maven
    stage('02 – Build with Maven') {
      steps {
        sh 'mvn -version'
        sh 'mvn -B -DskipTests=false clean compile'
      }
    }
    // Run unit tests and collect results
    stage('03 – Run Unit Tests') {
      steps {
        sh 'mvn -B test'
      }
      post {
        always {
          junit allowEmptyResults: false, testResults: 'target/surefire-reports/*.xml'
        }
      }
    }
    // Package the application as a WAR file
    stage('04 – Package WAR File') {
      steps {
        sh 'mvn -B package -DskipTests'
      }
      post {
        success {
          archiveArtifacts artifacts: 'target/*.war', fingerprint: true
        }
      }
    }
    // Deploy the WAR to Tomcat
    stage('05 – Deploy to Tomcat') {
      steps {
        script {
          def war = sh(returnStdout: true, script: "ls target/*.war | head -n1").trim()
          if (!war) { error "WAR not found in target/ - build/package failed." }
          echo "Found WAR: ${war}"

          if (env.DEPLOY_MODE == 'local') {
            echo "Deploying locally to ${env.TOMCAT_WEBAPPS}"
            sh "cp '${war}' '${TOMCAT_WEBAPPS}/'"
          } else if (env.DEPLOY_MODE == 'ssh') {
            sshagent([env.REMOTE_SSH_CREDENTIALS]) {
              sh "scp -o StrictHostKeyChecking=no ${war} jenkins@${env.REMOTE_HOST}:${env.TOMCAT_WEBAPPS}/"
            }
          } else if (env.DEPLOY_MODE == 'manager') {
            withCredentials([usernamePassword(credentialsId: env.TOMCAT_MANAGER_CREDENTIALS, usernameVariable: 'TM_USER', passwordVariable: 'TM_PASS')]) {
              def contextPath = "/${APP_NAME}"
              sh """
                curl -s -u ${TM_USER}:${TM_PASS} "${TOMCAT_MANAGER_URL}/undeploy?path=${contextPath}" || true
                curl -s -u ${TM_USER}:${TM_PASS} --upload-file ${war} "${TOMCAT_MANAGER_URL}/deploy?path=${contextPath}&update=true"
              """
            }
          } else {
            error "Unknown DEPLOY_MODE: ${env.DEPLOY_MODE}"
          }
        }
      }
    }
    // Simple smoke test to verify deployment
    stage('06 – Smoke Test') {
      steps {
        script {
          def url = "http://localhost:8080/${APP_NAME}/"
          echo "Running smoke test against ${url}"
          sh "sleep 5 || true"
          sh "curl -fsS ${url} > /dev/null"
        }
      }
    }
  }
    // Post actions for success/failure notifications and artifact archiving
  post {
    success {
      echo "✅ Pipeline succeeded for build #${env.BUILD_NUMBER}"
    }
    failure {
      echo "❌ Pipeline failed for build #${env.BUILD_NUMBER}"
    }
    always {
      archiveArtifacts allowEmptyArchive: true, artifacts: 'target/surefire-reports/**/*.xml'
    }
  }
}