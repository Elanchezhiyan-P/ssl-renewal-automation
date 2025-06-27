#!/bin/bash

# Configuration
domain="yourdomain.com"
log_file="/tmp/cert_renew_single.log"

> "$log_file"

check_certificate_expiry() {
    cert_file="/etc/letsencrypt/live/$domain/fullchain.pem"
    if [ ! -f "$cert_file" ]; then
        echo "[$(date)] ERROR: Certificate for $domain not found!" | tee -a "$log_file"
        return 999
    fi

    expiry_date=$(openssl x509 -enddate -noout -in "$cert_file" | cut -d= -f2)
    expiry_seconds=$(date --date="$expiry_date" +%s)
    current_seconds=$(date +%s)
    days_left=$(((expiry_seconds - current_seconds) / 86400))

    echo "[$(date)] $domain expires on: $expiry_date. Days left: $days_left" | tee -a "$log_file"
    echo $days_left
}

days_left=$(check_certificate_expiry)

if [ "$days_left" -eq 999 ]; then
    echo "[$(date)] Aborting due to missing cert." | tee -a "$log_file"
    exit 1
fi

if [ "$days_left" -lt 10 ]; then
    echo "[$(date)] Renewing certificate for $domain..." | tee -a "$log_file"
    /usr/bin/certbot renew --cert-name "$domain" --dry-run >> "$log_file" 2>&1

    if [ $? -eq 0 ]; then
        /usr/bin/certbot renew --cert-name "$domain" >> "$log_file" 2>&1
        if [ $? -eq 0 ]; then
            echo "[$(date)] Renewal successful. Restarting Nginx..." | tee -a "$log_file"
            sudo service nginx restart >> "$log_file" 2>&1
            if [ $? -eq 0 ]; then
                echo "[$(date)] Nginx restarted." | tee -a "$log_file"
            else
                echo "[$(date)] ERROR: Nginx restart failed!" | tee -a "$log_file"
            fi
        else
            echo "[$(date)] ERROR: Renewal failed!" | tee -a "$log_file"
        fi
    else
        echo "[$(date)] ERROR: Dry run failed!" | tee -a "$log_file"
    fi
else
    echo "[$(date)] Certificate valid for more than 10 days. No action needed." | tee -a "$log_file"
fi
