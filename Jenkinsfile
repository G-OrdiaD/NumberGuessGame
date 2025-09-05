pipeline {
  agent any

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '20'))
    ansiColor('xterm')
  }

  tools {
    jdk 'JDK-11'
    maven 'Maven-3.9'
  }

  environment {
    APP_NAME = "NumberGuessGame"
    TOMCAT_WEBAPPS = "/opt/tomcat/webapps"   // adjust to your Tomcat path
    DEPLOY_MODE = "local"                    // choose: local | ssh | manager
    REMOTE_HOST = ""                         // set if DEPLOY_MODE = ssh
    REMOTE_SSH_CREDENTIALS = "tomcat-ssh"    // Jenkins credential id for SSH
    TOMCAT_MANAGER_URL = ""                  // if using manager deploy
    TOMCAT_MANAGER_CREDENTIALS = "tomcat-manager-creds"
  }

  stages {

    stage('01 – Checkout Code') {
      steps {
        checkout scm
      }
    }

    stage('02 – Build with Maven') {
      steps {
        sh 'mvn -version'
        sh 'mvn -B -DskipTests=false clean compile'
      }
    }

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