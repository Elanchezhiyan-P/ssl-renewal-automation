# 🔐 SSL Certificate Expiry Checker & Auto-Renewer (Let's Encrypt)

This repository provides Bash scripts to **monitor and automatically renew Let's Encrypt SSL certificates** before they expire. It supports:

- ✅ Single domain
- ✅ Multiple domains

After renewal, the script automatically **restarts Nginx** to apply updated certificates.

---

## 📁 Scripts Included

### `check_ssl_renew_single.sh`
Monitors and renews the certificate for a **single domain**.

### `check_ssl_renew_multi.sh`
Monitors and renews certificates for **multiple domains**. Nginx is only restarted if at least one certificate is renewed.

---

## ⚙️ Requirements

- Certbot (Let's Encrypt client):
  ```bash
  sudo apt install certbot
  ```

- Existing certificates generated using Certbot (```certbot certonly``` or ```certbot --nginx```)

- Nginx installed and running

- Utilities: ```bash```, ```openssl```, ```cron```

---

## 🚀 Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/elanchezhiyan-p/ssl-renewal-automation.git
cd ssl-renewal-automation
```

### 2. Make the Script(s) Executable

```bash
chmod +x check_ssl_renew_single.sh
chmod +x check_ssl_renew_multi.sh
```
### 3. (Optional) Move to /usr/local/bin/ for global access

```bash
sudo mv check_ssl_renew_single.sh /usr/local/bin/
sudo mv check_ssl_renew_multi.sh /usr/local/bin/
```

---

## 🧪 Configure Your Domains

### For Single Domain
Edit the script:

```bash
domain="yourdomain.com"
```

### For Multiple Domains
Edit the array in check_ssl_renew_multi.sh:

```bash
domains=("example.com" "site.org" "anotherdomain.net")
```
---

## ⏰ Set Up Cron Job
### 🔄 Weekly Renewal Check – Every Sunday at 3:00 AM
Using [crontab.guru](https://crontab.guru/):

```bash
crontab -e
```
Add either of the following lines depending on the script:

### For Single Domain:
```c
0 3 * * 0 /usr/local/bin/check_ssl_renew_single.sh >> /var/log/ssl_renew_single.log 2>&1
```
### For Multiple Domains:
```c
0 3 * * 0 /usr/local/bin/check_ssl_renew_multi.sh >> /var/log/ssl_renew_multi.log 2>&1
```
✅ This runs every Sunday at 3:00 AM, ensuring certificates are renewed if they're expiring within the next 10 days.

---

## 📄 Logging
Logs are stored in:

```
/tmp/cert_renew_single.log or /var/log/ssl_renew_single.log

/tmp/cert_renew_multi.log or /var/log/ssl_renew_multi.log
```

You can change these paths in the script.

## 🧯 Notes

- Certificates are only renewed if they are less than 10 days from expiry

- certbot renew uses the ```--cert-name``` flag to target specific domain certificates

- You can adjust the check threshold by modifying if ```[ "$days_left" -lt 10 ];``` in the script


## 📬 Need Email or Webhook Alerts?

These scripts are easily extensible. If you'd like alerts via email, Slack, or webhook, feel free to open a PR or Issue.

## 📘 License
MIT – free to use, modify, and distribute.  

Let me know if you'd like a versioned release template or GitHub Actions CI workflow to test the script on push!