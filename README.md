# Secure shelter siem stack (under construction)

A ready‑to‑use, TLS‑encrypted, and pre‑dashboarded Security Information & Event Management (SIEM) stack for shelters.
Detects common malware, network anomalies, and stalkerware (BadBox, BadBox2, mFly, FlexiSpy, Spynger, etc.) right from first boot.

Includes:

* **WireGuard VPN** for secure remote access
* **Wazuh Manager** for endpoint & log monitoring
* **Suricata IDS** for network intrusion detection
* **Zeek** for network analysis
* **Filebeat** for log shipping over TLS
* **Elasticsearch** with self‑signed TLS
* **Kibana** with pre‑loaded dashboards

---

## 1. Requirements

Minimum for small shelters (up to 10 monitored devices):

* 4 CPU cores
* 8 GB RAM (16 GB recommended)
* 200 GB SSD storage (logs grow quickly)
* One **dedicated NIC** in promiscuous mode for packet capture
* Linux host (Ubuntu 22.04 LTS recommended)
* Docker & Docker Compose installed

---

## 2. First‑time setup

### Clone the repository

```bash
git clone https://example.org/shelter-siem-stack.git
cd shelter-siem-stack
```

### Copy and edit environment variables

```bash
cp .env.example .env
nano .env
```

Set secure passwords for:

* `ELASTIC_PASSWORD`
* `KIBANA_PASSWORD`
* `WAZUH_PASSWORD`

---

## 3. Start the WireGuard VPN (required)

All access to Kibana, Elasticsearch, and Wazuh is **through the VPN** — nothing is exposed to the public internet.

From the repo root:

```bash
docker-compose up -d vpn
```

The VPN server listens on UDP/51820.
The default VPN subnet gateway is `10.13.13.1`.

---

## 4. Add VPN peers (staff, responders, remote agents)

To add a new peer:

```bash
./vpn/add-peer.sh <peer-name>
```

Example:

```bash
./vpn/add-peer.sh alice
```

This will:

* Create a WireGuard peer named `alice`
* Assign it an IP in the VPN subnet
* Save the configuration to `vpn/alice.conf`

**Send `alice.conf` securely** to the user — they can import it into the WireGuard client on Windows, macOS, Linux, Android, or iOS.

---

## 5. Generate TLS certificates for Elasticsearch

Run:

```bash
./scripts/gen-certs.sh
```

Creates:

```
config/elasticsearch/certs/elastic-stack-ca.p12
config/elasticsearch/certs/elastic-certificates.p12
```

Password is set in `.env` — change it if you wish.

---

## 6. Update detection rules

Fetch latest Suricata rules:

```bash
./scripts/update-rules.sh
```

Sources:

* Emerging Threats (v7.0.3)
* AbuseCH SSL blacklist
* Local `custom.rules` for stalkerware detection

---

## 7. Deploy the SIEM stack

```bash
./scripts/deploy.sh
```

Starts:

* Elasticsearch with TLS
* Kibana (imports dashboards from `config/dashboards/`)
* Wazuh Manager
* Suricata & Zeek
* Filebeat with TLS to Elasticsearch

---

## 8. Access dashboards (via VPN)

Connect to the VPN with your peer config, then open:

```
http://10.13.13.1:5601
```

Login:

* **Username:** `kibana_system` (from `.env`)
* **Password:** your `KIBANA_PASSWORD`

Dashboards available:

* **Threat Overview**: alerts across all sources
* **High Risk Devices**: endpoints with repeated detections
* **Network Anomalies**: suspicious traffic patterns
* **Stalkerware Watchlist**: detections for BadBox, mFly, FlexiSpy, Spynger

---

## 9. Deploy Wazuh agents

On a monitored endpoint (inside VPN or local network):

```bash
curl -so wazuh-agent.deb https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.12.0-1_amd64.deb \
 && sudo WAZUH_MANAGER='10.13.13.1' dpkg -i ./wazuh-agent.deb \
 && sudo systemctl enable wazuh-agent --now
```

---

## 10. Maintenance

* **Stop stack**: `./scripts/stop.sh`
* **Backup data**: runs nightly to `/mnt/secure-backup`
* **Restore backup**: `./scripts/restore-backup.sh`
* **Update rules weekly**: `./scripts/update-rules.sh`

---

## 11. Network interface requirements

If using Suricata/Zeek in packet capture mode:

* Set `SNIFFING_INTERFACE` in `.env` (e.g., `eth1`)
* Put interface in promiscuous mode:

```bash
sudo ip link set eth1 promisc on
```

---

## 12. Security notes

* Change all default passwords in `.env` before deployment
* Store VPN peer configs securely
* Keep Elasticsearch TLS certs private
* Monitor disk usage (`./data/elasticsearch`) — prune old indices when needed

---

Ready to monitor, detect, and defend.


