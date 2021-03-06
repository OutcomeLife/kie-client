#!/bin/sh
  KEYCLOAK_JSON_FILE=/opt/realm/keycloak.json
  CLUSTER_XML_FILE=/opt/cluster.xml
  JAVA_OPT_KEYCLOAK_PATH=-Dswarm.keycloak.json.path=$KEYCLOAK_JSON_FILE


# change the package.json file
function escape_slashes {
    /bin/sed 's/\//\\\//g'
}

function change_line {
  eval OLD_LINE_PATTERN="$1"
  eval NEW_LINE="$2"
  eval FILE="$3"

    local NEW=$(echo "${NEW_LINE}" | escape_slashes)
    /bin/sed -i  '/'"${OLD_LINE_PATTERN}"'/s/.*/'"${NEW}"'/' "${FILE}"
}
function change_line2 {
  eval OLD_LINE_PATTERN="$1"
  eval NEW_LINE="$2"
  eval FILE="$3"

    local NEW=$(echo "${NEW_LINE}" | escape_slashes)
    /bin/sed -i  '/'"${OLD_LINE_PATTERN}"'/s/.*/'"${NEW}"'/' "${FILE}"
}

if [ -z "${KEYCLOAKURL}" ]; then
   echo "No KEYCLOAKURL given. No change to keycloak.json"
else
   OLD_LINE_KEY="auth-server-url"
   NEW_LINE="\"auth-server-url\": \"${KEYCLOAKURL}\","
   change_line "\${OLD_LINE_KEY}" "\${NEW_LINE}" "\${KEYCLOAK_JSON_FILE}"
fi

   OLD_LINE_KEY="<interface>10\.1\.1\.\*<\/interface>"
   NEW_LINE="<interface>${HOSTIP}</interface>"
   change_line2 "\${OLD_LINE_KEY}" "\${NEW_LINE}" "\${CLUSTER_XML_FILE}"

#Set some ENV by extracting from keycloak.json file
export KEYCLOAK_REALM=`jq '.realm' /opt/realm/keycloak.json`
export KEYCLOAK_URL=`jq '.["auth-server-url"]' /opt/realm/keycloak.json`
export KEYCLOAK_CLIENTID=`jq '.resource' /opt/realm/keycloak.json`
export KEYCLOAK_SECRET=`jq '.secret' /opt/realm/keycloak.json`

echo "KEYCLOAK REALM= ${KEYCLOAK_REALM}"
echo "KEYCLOAK URL= ${KEYCLOAK_URL}"
echo "KEYCLOAK CLIENTID= ${KEYCLOAK_CLIENTID}"

java -jar ${JAVA_OPT_KEYCLOAK_PATH}   -Djava.net.preferIPv6Addresses=false   -Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Addresses=true   kie-client-0.0.1-SNAPSHOT-fat.jar 


