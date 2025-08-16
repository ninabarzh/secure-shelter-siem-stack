#!/bin/bash
set -e

SURICATA_RULES_DIR="./config/suricata/rules"
ZEEK_SCRIPTS_DIR="./config/zeek/scripts"

# Ensure directories exist
mkdir -p "$SURICATA_RULES_DIR"
mkdir -p "$ZEEK_SCRIPTS_DIR"

echo "[*] Updating Suricata Emerging Threats rules 7.0.3..."
curl -sSL "http://rules.emergingthreats.net/open/suricata-7.0.3/emerging-all.rules.tar.gz" \
  | tar xz -C $SURICATA_RULES_DIR --strip-components=1

echo "[*] Updating Abuse.ch ThreatFox intel..."
curl -sSL https://threatfox-api.abuse.ch/export/suricata | grep -v '^#' \
  > $SURICATA_RULES_DIR/abusech.rules

echo "[*] Adding custom stalkerware rules (if any)..."
cp ./intel/custom.rules $SURICATA_RULES_DIR/custom.rules || true

echo "[*] Fetching malware JA3 signatures from Abuse.ch SSLBL (testing only)..."
curl -sSL https://sslbl.abuse.ch/blacklist/ja3_fingerprints.csv \
  | grep -v '^#' | awk -F',' '{print $1}' \
  > $ZEEK_SCRIPTS_DIR/stalkerware-ja3.zeek

# Minimal Zeek detector script
DETECTOR_FILE="$ZEEK_SCRIPTS_DIR/stalkerware-ja3-detector.zeek"
if [ ! -f "$DETECTOR_FILE" ]; then
    echo "[*] Creating minimal Zeek detector script..."
    cat << 'EOF' > "$DETECTOR_FILE"
# Minimal stalkerware JA3 detector
module Stalkerware;

export {
    redef set[string] &JA3::hash_list = set();
}

event zeek_init()
    {
    local path = fmt("%s/stalkerware-ja3.zeek", getenv("ZEEK_SCRIPT_DIR"));
    if ( path != "" )
        {
        local file = open(path);
        if ( file != nil )
            {
            local line: string;
            while ( (line = read_file_line(file)) != "" )
                {
                line = strip(line);
                if ( line != "" )
                    add JA3::hash_list[line];
                }
            close(file);
            }
        }
    }

event tls_client_hello(c: connection)
    {
    if ( c?$ssl )
        {
        local ja3 = c$ssl$ja3;
        if ( ja3 in JA3::hash_list )
            {
            print fmt("ALERT: JA3 match for suspected stalkerware C2: %s (conn %s)",
                      ja3, c$id);
            }
        }
    }
EOF
fi

echo "[*] Rule update complete."
