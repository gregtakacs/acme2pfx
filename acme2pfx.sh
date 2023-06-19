#!/bin/sh
echo $CERT_KEY_FILE
jq -r '.[env.CERT_RESOLVER].Certificates[] | select(.domain.main==env.CERT_DOMAIN) | .certificate' /source/acme.json  | base64 -d > $TMP_DIR/tls_cert.pem
jq -r '.[env.CERT_RESOLVER].Certificates[] | select(.domain.main==env.CERT_DOMAIN) | .key' /source/acme.json  | base64 -d > $TMP_DIR/tls_key.pem
openssl pkcs12 -export -out /dest/$CERT_DOMAIN.pfx -inkey $TMP_DIR/tls_key.pem -in $TMP_DIR/tls_cert.pem -name $CERT_DOMAIN -passout file:$CERT_KEY_FILE
rm $TMP_DIR/tls_key.pem $TMP_DIR/tls_cert.pem
