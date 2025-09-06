set -euo pipefail

# === Config ===
TOMCAT_HOME="/opt/tomcat"
WAR_PATH="target/NumberGuessGame-1.0-SNAPSHOT.war"   # leave as Maven built it

# === Build ===
echo "[1/4] Building WAR with Maven..."
mvn clean package -DskipTests

# === Undeploy old app ===
echo "[2/4] Removing previous deployment (if any)..."
sudo rm -rf "${TOMCAT_HOME}/webapps/NumberGuessGame-1.0-SNAPSHOT" \
            "${TOMCAT_HOME}/webapps/NumberGuessGame-1.0-SNAPSHOT.war" || true

# === Deploy new WAR ===
echo "[3/4] Copying new WAR to Tomcat webapps..."
sudo cp "${WAR_PATH}" "${TOMCAT_HOME}/webapps/"

# === Restart Tomcat ===
echo "[4/4] Restarting Tomcat..."
sudo "${TOMCAT_HOME}/bin/shutdown.sh" || true
sleep 2
sudo "${TOMCAT_HOME}/bin/startup.sh"

echo "Deployment complete!"
echo "App available at: http://<EC2-Public-IP>:8080/NumberGuessGame-1.0-SNAPSHOT"

