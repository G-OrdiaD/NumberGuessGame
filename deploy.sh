
set -euo pipefail

# === Config ===
TOMCAT_HOME="/opt/tomcat"
WAR_SOURCE="target/NumberGuessGame-1.0-SNAPSHOT.war" # Path to the built WAR file
DEPLOY_NAME="NumberGuessGame-1.0-SNAPSHOT" # Name of the deployed app


# === Undeploy old app ===
echo "[1/3] Removing previous deployment (if any)..."
sudo rm -rf "${TOMCAT_HOME}/webapps/${DEPLOY_NAME}" \
            "${TOMCAT_HOME}/webapps/${DEPLOY_NAME}.war" || true

# === Deploy new WAR ===
echo "[2/3] Copying new WAR to Tomcat webapps..."
sudo cp "${WAR_SOURCE}" "${TOMCAT_HOME}/webapps/${DEPLOY_NAME}.war"

# === Restart Tomcat ===
echo "[3/3] Restarting Tomcat..."
sudo "${TOMCAT_HOME}/bin/shutdown.sh" || true
sleep 2
sudo "${TOMCAT_HOME}/bin/startup.sh"

echo "Deployment complete!"
echo "App available at: http://localhost:8081/${DEPLOY_NAME}"

