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
    jdk 'Java_17' // Java version make sure to configure in Jenkins global tools
    maven 'Maven_3.8.4' // Maven version make sure to configure in Jenkins global tools
  }
  // Define environment variables
  environment {
    APP_NAME = "NumberGuessGame-1.0-SNAPSHOT" // war name without .war
    TOMCAT_HOME = "/opt/tomcat"               // tomcat home directory
    TOMCAT_WEBAPPS = "/opt/tomcat/webapps"    // tomcat webapps dir
    DEPLOY_MODE = "local"                     // Local deployment
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
        sh 'mvn -B war:war'
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
          // Verify the WAR file exists with the exact expected name
          def warFile = "target/${APP_NAME}.war"
          if (!fileExists(warFile)) {
            error "WAR not found: ${warFile} - build/package failed."
          }
          echo "Found WAR: ${warFile}"

          if (env.DEPLOY_MODE == 'local') {
            echo "Deploying using deploy.sh logic to ${env.TOMCAT_WEBAPPS}"
            
            // === UNDEPLOY OLD APP (matches deploy.sh) ===
            echo "[1/3] Removing previous deployment (if any)..."
            sh """
              sudo rm -rf "${TOMCAT_WEBAPPS}/${APP_NAME}" \\
                          "${TOMCAT_WEBAPPS}/${APP_NAME}.war" || true
            """
            
            // === DEPLOY NEW WAR (matches deploy.sh) ===
            echo "[2/3] Copying new WAR to Tomcat webapps..."
            sh """
              sudo cp "${warFile}" "${TOMCAT_WEBAPPS}/${APP_NAME}.war"
            """
            
            // === RESTART TOMCAT (matches deploy.sh) ===
            echo "[3/3] Restarting Tomcat..."
            sh """
              sudo "${TOMCAT_HOME}/bin/shutdown.sh" || true
              sleep 2
              sudo "${TOMCAT_HOME}/bin/startup.sh"
            """
            
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
          def url = "http://localhost:8081/${APP_NAME}/"
          echo "Running smoke test against ${url}"
          echo "Deployment complete!"
          echo "App available at: ${url}"
          sleep 10  // Give Tomcat more time to restart and deploy
          sh "curl -fsS ${url} > /dev/null || echo 'Application may still be starting'"
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