# Number Guessing Game 🎯
A simple Java web app for guessing numbers (1–100).

## Project Overview 📋 

A fully automated CI/CD pipeline for a Java web application using Jenkins, Maven, and Tomcat. This project demonstrates modern DevOps practices with complete automation from code commit to production deployment.

 ## Technical Stack 🛠️

Frontend: JSP, HTML, CSS
Backend: Java Servlets
Build Tool: Apache Maven
CI/CD Server: Jenkins
Application Server: Apache Tomcat 9
Version Control: GitHub

## Pipeline Stages 🔧 

✅ Code Checkout - Automated git clone from GitHub
✅ Compile & Build - Maven compilation and packaging
✅ Unit Testing - Automated JUnit test execution
✅ WAR Packaging - Executable web archive creation
✅ Automated Deployment - Zero-downtime deployment to Tomcat
✅ Smoke Testing - Automated verification of deployed application

## Automation Features 🤖 

GitHub Webhooks: Automatic build triggering on every git push
Self-healing Pipeline: Automatic rollback on deployment failures
Artifact Archiving: Historical build artifacts stored in Jenkins
Email Notifications: Build status alerts to team members
Quality Gates: Automated testing before deployment

## How to build & run locally
```bash
mvn clean test
mvn package
```

## Team Roles & Responsibilities 👥

## Pipeline Lead
Jenkins pipeline configuration & maintenance
Webhook setup and automation triggers
CI/CD workflow optimization
Build monitoring and troubleshooting

## Deployment Lead
Tomcat server setup and configuration
WAR deployment automation
Environment management (dev/test/prod)
Performance optimization

## Repo & Quality Lead
GitHub repository management
Code review enforcement
Documentation maintenance
Quality assurance standards

## Troubleshooting 🚨

If automation fails:

1. Check Jenkins build console for errors
2. Verify Tomcat server status: sudo systemctl status tomcat
3. Confirm webhook delivery in GitHub settings
4. Check application logs: /opt/tomcat/logs/catalina.out