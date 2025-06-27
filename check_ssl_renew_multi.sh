#!/bin/bash

# List all your domains here (space separated)
domains=("example.com" "site.org" "anotherdomain.net")
log_file="/tmp/cert_renew_multi.log"
> "$log_file"

check_and_renew() {
    local domain=$1
    cert_file="/etc/letsencrypt/live/$domain/fullchain.pem"
    if [ ! -f "$cert_file" ]; then
        echo "[$(date)] ERROR: Certificate for $domain not found!" | tee -a "$log_file"
        return 1
    fi

    expiry_date=$(openssl x509 -enddate -noout -in "$cert_file" | cut -d= -f2)
    expiry_seconds=$(date --date="$expiry_date" +%s)
    current_seconds=$(date +%s)
    days_left=$(((expiry_seconds - current_seconds) / 86400))

    echo "[$(date)] $domain expires on: $expiry_date. Days left: $days_left" | tee -a "$log_file"

    if [ "$days_left" -lt 10 ]; then
        echo "[$(date)] Renewing $domain certificate..." | tee -a "$log_file"
        /usr/bin/certbot renew --cert-name "$domain" --dry-run >> "$log_file" 2>&1

        if [ $? -eq 0 ]; then
            /usr/bin/certbot renew --cert-name "$domain" >> "$log_file" 2>&1
            if [ $? -eq 0 ]; then
                echo "[$(date)] Renewal successful for $domain." | tee -a "$log_file"
                return 0
            else
                echo "[$(date)] ERROR: Renewal failed for $domain!" | tee -a "$log_file"
                return 1
            fi
        else
            echo "[$(date)] ERROR: Dry run failed for $domain!" | tee -a "$log_file"
            return 1
        fi
    else
        echo "[$(date)] No renewal needed for $domain." | tee -a "$log_file"
        return 0
    fi
}

any_renewed=0

for domain in "${domains[@]}"; do
    check_and_renew "$domain"
    if [ $? -eq 0 ]; then
        any_renewed=1
    fi
done

if [ "$any_renewed" -eq 1 ]; then
    echo "[$(date)] Restarting Nginx after renewal(s)..." | tee -a "$log_file"
    sudo service nginx restart >> "$log_file" 2>&1
    if [ $? -eq 0 ]; then
        echo "[$(date)] Nginx restarted successfully." | tee -a "$log_file"
    else
        echo "[$(date)] ERROR: Nginx restart failed!" | tee -a "$log_file"
    fi
else
    echo "[$(date)] No certificates renewed; skipping Nginx restart." | tee -a "$log_file"
fi
