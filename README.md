# Secure shelter siem stack (under construction)

A ready-to-use, hardened SIEM stack for shelters and crisis centres: Monitors network and endpoints for intrusions, 
stalkerware, and other abuseware — with pre‑built dashboards and daily threat intel updates.

---

## Features

- Wazuh + Elasticsearch + Kibana SIEM stack
- Zeek & Suricata network monitoring with custom stalkerware rules
- VPN‑only access (WireGuard)
- TLS between all services
- Pre‑set RBAC accounts (admin, viewer)
- Daily rule and intel updates
- Encrypted nightly backups to local 500 GB disk
- Pre‑built Kibana dashboards for:
  - Threat overview
  - Stalkerware watchlist
  - Network anomalies
  - High‑risk devices

---

## Requirements

**Host system:**
- Linux server (Debian 12, Ubuntu 22.04 LTS, Rocky Linux 9 tested)
- Docker + Docker Compose v2
- Minimum:
  - CPU: 4 cores (8+ recommended)
  - RAM: 8 GB (16 GB recommended)
  - Storage: 200 GB SSD for data + **separate 500 GB disk** for backups
- **Dedicated sniffing NIC**:
  - A second network interface card connected to the network you want to monitor
  - Must not have an IP address assigned
  - Example: `eth1` on Linux
  - Can be a USB 3.0 Gigabit Ethernet adapter if no free PCIe slot
- Internet connection (for rule updates, unless using offline feed)

**Client devices (for VPN access):**

- WireGuard client installed (Windows, macOS, Linux, iOS, or Android)

---

## quick start

1. Clone the repository:

```bash
git clone https://github.com/yourorg/shelter-siem-secure.git
cd shelter-siem-secure
````

2. Create `.env` from example and set your sniffing NIC name:

```bash
cp .env.example .env
nano .env
# Set SNIFFING_INTERFACE=eth1 (or your NIC)
```

3. Deploy the stack:

```bash
./scripts/deploy.sh
```

4. Import the generated VPN config from `./vpn` into your WireGuard client.

5. Connect to the VPN, then open in your browser:

* **Kibana:** `https://siem.local:5601`
* **Wazuh API:** `https://siem.local:55000`

---

## Dashboards

After first login, you will see:

* **Threat Overview:** Summary of all alerts
* **Stalkerware Watchlist:** Detections for BadBox, BadBox2, mFly, FlexiSpy, Spynger, and others
* **Network Anomalies:** Suricata/Zeek events outside normal patterns
* **High‑risk Devices:** Endpoints with multiple stalkerware indicators

---

## Backups

* Run nightly at 02:00
* Encrypted with GPG
* Stored on `/mnt/secure-backup` (500 GB disk)
* On first run, generates `config/backup/backup-key.gpg`
* **Copy the key to a USB stick and lock it away** — without it, backups cannot be restored

### Restore

```bash
gpg --import config/backup/backup-key.gpg
gpg --decrypt /mnt/secure-backup/shelter-siem-YYYY-MM-DD_HH-MM.tar.gz.gpg | tar -xz -C data/
```

---

## Maintenance

### Update rules manually

```bash
./scripts/update-rules.sh
docker compose restart suricata zeek
```

### Update stack

```bash
docker compose pull && docker compose up -d
```

---

## Security notes

* All access is via VPN — never expose ports 9200, 5601, 55000 to the internet
* Keep the backup disk physically secure
* Regularly test VPN configs and backups


