#!/bin/bash
set -e
CERT_DIR="./config/elasticsearch/certs"
PASSWORD="changeit"

mkdir -p "$CERT_DIR"

echo "[*] Generating Elasticsearch self-signed CA and certificates..."
docker run --rm -v "$PWD/$CERT_DIR":/certs \
  docker.elastic.co/elasticsearch/elasticsearch:8.14.3 \
  bash -c "
    elasticsearch-certutil ca --out /certs/elastic-stack-ca.p12 --pass $PASSWORD &&
    elasticsearch-certutil cert --ca /certs/elastic-stack-ca.p12 --ca-pass $PASSWORD \
      --out /certs/elastic-certificates.p12 --pass $PASSWORD &&
    chown 1000:0 /certs/*.p12
  "

echo "[*] Certificates created in $CERT_DIR"
echo "    Keystore/truststore password: $PASSWORD"
