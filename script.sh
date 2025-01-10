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
