#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <peer-name>"
  exit 1
fi

PEER_NAME="$1"
VPN_DIR="$(dirname "$0")"

docker exec -it vpn /app/add-peer "$PEER_NAME"

# Copy generated config out of container
PEER_CONF="$VPN_DIR/$PEER_NAME.conf"
docker exec vpn cat "/config/$PEER_NAME/peer_$PEER_NAME.conf" > "$PEER_CONF"

echo "[+] Peer config for '$PEER_NAME' saved to $PEER_CONF"
echo "    Transfer this file securely to the peer and import into WireGuard."
