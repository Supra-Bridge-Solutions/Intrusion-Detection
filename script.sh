#!/bin/bash

CRITICAL_FILES=("/etc/passwd" "/etc/shadow" "/etc/group") # Files to monitor
CHECKSUM_FILE="/var/log/critical_files_checksums.txt"     # Store checksums
LOG_FILE="/var/log/intrusion_detection.log"              # Log file
TRIPWIRE_CMD="tripwire --check"                          # Command to run Tripwire
CHKROOTKIT_CMD="chkrootkit"                              # Command to run chkrootkit

# Initialize the log file
echo "Intrusion Detection Script - $(date)" > $LOG_FILE

# Function to calculate and verify checksums
check_file_integrity() {
    echo "Checking file integrity..." >> $LOG_FILE
    for FILE in "${CRITICAL_FILES[@]}"; do
        if [[ -f $FILE ]]; then
            NEW_CHECKSUM=$(sha256sum "$FILE" | awk '{print $1}')
            OLD_CHECKSUM=$(grep "$FILE" $CHECKSUM_FILE | awk '{print $2}')
            if [[ "$NEW_CHECKSUM" != "$OLD_CHECKSUM" ]]; then
                echo "[ALERT] File modified: $FILE" | tee -a $LOG_FILE
            fi
            # Update checksum
            sed -i "/$FILE/d" $CHECKSUM_FILE
            echo "$FILE $NEW_CHECKSUM" >> $CHECKSUM_FILE
        else
            echo "[ALERT] Critical file missing: $FILE" | tee -a $LOG_FILE
        fi
    done
}


# Function to detect new or modified user accounts
check_user_accounts() {
    echo "Checking user accounts..." >> $LOG_FILE
    # Use a snapshot of /etc/passwd
    if [[ ! -f /var/log/passwd_snapshot ]]; then
        cp /etc/passwd /var/log/passwd_snapshot
    fi
    diff /var/log/passwd_snapshot /etc/passwd > /tmp/passwd_diff.txt
    if [[ -s /tmp/passwd_diff.txt ]]; then
        echo "[ALERT] Changes detected in /etc/passwd:" >> $LOG_FILE
        cat /tmp/passwd_diff.txt >> $LOG_FILE
        cp /etc/passwd /var/log/passwd_snapshot
    fi
}

# Function to scan for suspicious processes
check_suspicious_processes() {
    echo "Checking for suspicious processes..." >> $LOG_FILE
    ps aux | awk '$3 > 50.0 || $4 > 50.0 {print "[ALERT] High resource usage detected:", $0}' >> $LOG_FILE
}

# Function to integrate with Tripwire
check_with_tripwire() {
    echo "Running Tripwire check..." >> $LOG_FILE
    if command -v tripwire &> /dev/null; then
        $TRIPWIRE_CMD >> $LOG_FILE 2>&1
    else
        echo "[WARNING] Tripwire is not installed. Skipping this step." >> $LOG_FILE
    fi
}

# Function to integrate with chkrootkit
check_with_chkrootkit() {
    echo "Running chkrootkit..." >> $LOG_FILE
    if command -v chkrootkit &> /dev/null; then
        $CHKROOTKIT_CMD >> $LOG_FILE 2>&1
    else
        echo "[WARNING] chkrootkit is not installed. Skipping this step." >> $LOG_FILE
    fi
}

# Main script execution
echo "Starting intrusion detection checks..." >> $LOG_FILE

check_file_integrity
check_user_accounts
check_suspicious_processes
check_with_tripwire
check_with_chkrootkit

echo "Intrusion detection checks completed - $(date)" >> $LOG_FILE
echo "Logs available at $LOG_FILE"

# Schedule the script with cron (optional)
# Example: Add this line to your crontab
# 0 * * * * /path/to/this/script.sh