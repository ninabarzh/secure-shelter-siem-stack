# Secure shelter siem stack (under construction)

A ready‑to‑use, TLS‑encrypted, and pre‑dashboarded Security Information & Event Management (SIEM) stack for shelters.
It detects common malware, network anomalies, and stalkerware (BadBox, BadBox2, mFly, FlexiSpy, Spynger, etc.) right from first boot.

Includes:

* Wazuh Manager for endpoint & log monitoring
* Suricata IDS for network intrusion detection
* Zeek for network analysis
* Filebeat for log shipping over TLS
* Elasticsearch with self‑signed TLS
* Kibana with pre‑loaded dashboards

---

## Requirements

Minimum for small shelters (up to 10 monitored devices):

* 4 CPU cores
* 8 GB RAM (16 GB recommended)
* 200 GB SSD storage (logs grow quickly)
* One dedicated NIC in promiscuous mode for packet capture
* Linux host (Ubuntu 22.04 LTS recommended)
* Docker & Docker Compose installed

---

## First‑time setup

### Clone the repository

```bash
git clone https://github.com/ninabarzh/secure-shelter-siem-stack.git
cd secure-shelter-siem-stack
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

## Generate TLS certificates

Run:

```bash
./scripts/gen-certs.sh
```

This will create:

```
config/elasticsearch/certs/elastic-stack-ca.p12
config/elasticsearch/certs/elastic-certificates.p12
```

Password: `changeit` (also set in configs — you may change it if desired).

---

## Update detection rules

Fetch latest Suricata rules:

```bash
./scripts/update-rules.sh
```

This pulls:

* Emerging Threats (v7.0.3)
* AbuseCH SSL blacklist
* Local `custom.rules` for stalkerware

---

## Deploy the stack

```bash
./scripts/deploy.sh
```

This will:

* Start Elasticsearch with TLS
* Start Kibana (will auto‑import dashboards from `config/dashboards/`)
* Start Wazuh Manager
* Start Suricata & Zeek
* Start Filebeat with TLS output to Elasticsearch

---

## Accessing the dashboards

Open:

```
http://<server-ip>:5601
```

Login:

* Username: `kibana_system` (from `.env`)
* Password: your chosen `KIBANA_PASSWORD`

You will see:

* Threat Overview: global picture of alerts
* High Risk Devices: devices with repeated detections
* Network Anomalies: traffic spikes, suspicious protocols
* Stalkerware Watchlist: matches on BadBox, mFly, FlexiSpy, Spynger, etc.

---

## Deploy Wazuh agents

On a monitored endpoint:

```bash
curl -so wazuh-agent.deb https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.12.0-1_amd64.deb \
 && sudo WAZUH_MANAGER='<server-ip>' dpkg -i ./wazuh-agent.deb \
 && sudo systemctl enable wazuh-agent --now
```

---

## Stopping and restarting

Stop:

```bash
./scripts/stop.sh
```

Restart:

```bash
./scripts/deploy.sh
```

---

## Restoring from backup

To restore from a previous backup:

```bash
./scripts/restore-backup.sh
```

---

## Security notes

* Change all default passwords in `.env` before going live.
* Keep Elasticsearch TLS certs private (`config/elasticsearch/certs`).
* Use `./scripts/update-rules.sh` weekly.
* Monitor disk usage in `./data/elasticsearch` — prune old indices if space runs low.

---

## Network interface requirements

If using Suricata/Zeek in packet capture mode:

* Set `SNIFFING_INTERFACE` in `.env` to your dedicated NIC (e.g., `eth1`).
* This interface must be in promiscuous mode:

```bash
sudo ip link set eth1 promisc on
```

---

## Dashboards included

Location: `config/dashboards/`

* `threat-overview.ndjson`
* `high-risk-devices.ndjson`
* `network-anomalies.ndjson`
* `stalkerware-watchlist.ndjson`

These are auto‑loaded at first Kibana startup.

---

## Rule sources

* Emerging Threats: `https://rules.emergingthreats.net/open/suricata-7.0.3/`
* AbuseCH SSL Blacklist: `https://sslbl.abuse.ch/blacklist/sslblacklist.rules`
* Local custom rules: `intel/custom.rules`

---

Ready to monitor, detect, and defend.


