#!/bin/bash

# -------------------------------
# Bug Bounty Recon Pipeline
# -------------------------------
# Usage: ./recon_pipeline.sh target.com
# Requires: subfinder, amass, httpx
# -------------------------------

# check arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 target.com"
    exit 1
fi

TARGET=$1
DATE=$(date +%Y%m%d_%H%M)
OUTPUT_DIR="labs/recon_$TARGET_$DATE"

mkdir -p $OUTPUT_DIR

echo "[*] Starting Recon Pipeline for $TARGET"
echo "[*] Output directory: $OUTPUT_DIR"

# Step 1: Subdomain Enumeration
echo "[*] Running subfinder..."
subfinder -d $TARGET -o $OUTPUT_DIR/subfinder.txt

echo "[*] Running amass enum..."
amass enum -d $TARGET -o $OUTPUT_DIR/amass.txt

# Combine and sort unique subdomains
cat $OUTPUT_DIR/subfinder.txt $OUTPUT_DIR/amass.txt | sort -u > $OUTPUT_DIR/all_subdomains.txt
echo "[*] Total unique subdomains saved to all_subdomains.txt"

# Step 2: Check which hosts are alive
echo "[*] Checking alive hosts with httpx..."
cat $OUTPUT_DIR/all_subdomains.txt | httpx -silent -o $OUTPUT_DIR/alive_hosts.txt
echo "[*] Alive hosts saved to alive_hosts.txt"

# Step 3: Summary
echo "-----------------------------------"
echo "[*] Recon complete for $TARGET"
echo "[*] Subdomains found: $(wc -l < $OUTPUT_DIR/all_subdomains.txt)"
echo "[*] Alive hosts found: $(wc -l < $OUTPUT_DIR/alive_hosts.txt)"
echo "[*] All outputs saved in $OUTPUT_DIR"
echo "-----------------------------------"
