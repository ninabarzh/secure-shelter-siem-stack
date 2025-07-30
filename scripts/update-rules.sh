#!/bin/bash
set -e
SURICATA_RULES_DIR="./config/suricata/rules"
ZEEK_SCRIPTS_DIR="./config/zeek/scripts"

echo "[*] Updating Suricata Emerging Threats rules 7.0.3..."
curl -sSL "http://rules.emergingthreats.net/open/suricata-7.0.3/emerging-all.rules.tar.gz" | tar xz -C $SURICATA_RULES_DIR --strip-components=1

echo "[*] Updating Abuse.ch ThreatFox intel..."
curl -sSL https://threatfox-api.abuse.ch/export/suricata | grep -v '^#' > $SURICATA_RULES_DIR/abusech.rules

echo "[*] Adding custom stalkerware rules..."
cp ./intel/custom.rules $SURICATA_RULES_DIR/custom.rules

echo "[*] Fetching stalkerware JA3 signatures for Zeek..."
curl -sSL https://example-feed.org/stalkerware-ja3.txt > $ZEEK_SCRIPTS_DIR/stalkerware-ja3.zeek

echo "[*] Rule update complete."
