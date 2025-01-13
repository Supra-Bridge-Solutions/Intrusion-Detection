check_file_integrity() {
    echo "Checking file integrity..." >> $LOG_FILE
    # Ensure checksum file exists
    if [[ ! -f $CHECKSUM_FILE ]]; then
        log_message "INFO" "Checksum file does not exist. Creating a new one."
        touch $CHECKSUM_FILE
    fi

    for FILE in "${CRITICAL_FILES[@]}"; do
        if [[ -f $FILE ]]; then
            NEW_CHECKSUM=$(sha256sum "$FILE" | awk '{print $1}')
            OLD_CHECKSUM=$(grep "$FILE" $CHECKSUM_FILE | awk '{print $2}')
            
            if [[ "$NEW_CHECKSUM" != "$OLD_CHECKSUM" ]]; then
                log_message "ALERT" "File modified: $FILE"
            fi

            # Update checksum (only if modified)
            if [[ "$NEW_CHECKSUM" != "$OLD_CHECKSUM" ]]; then
                sed -i "/$FILE/d" $CHECKSUM_FILE
                echo "$FILE $NEW_CHECKSUM" >> $CHECKSUM_FILE
            fi
        else
            log_message "ALERT" "Critical file missing: $FILE"
        fi
    done
}

check_file_integrity