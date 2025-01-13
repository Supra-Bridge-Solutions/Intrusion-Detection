#!/bin/bash

# Define the path to your scripts
CHECK_FILE_INTEGRITY="./check_file_integrity.sh"
REQUIREMENTS="./requirements.sh"
SCRIPT_A="./script_A.sh"

# Log file for the main script
LOG_FILE="/var/log/intrusion_detection_main.log"
echo "Intrusion Detection System - Main Script" > $LOG_FILE

# Check if required scripts exist before calling them
if [[ -f $CHECK_FILE_INTEGRITY ]]; then
    echo "[INFO] Running check_file_integrity.sh..." | tee -a $LOG_FILE
    source $CHECK_FILE_INTEGRITY
    check_file_integrity # Call the function if `source` was used
else
    echo "[ERROR] check_file_integrity.sh not found!" | tee -a $LOG_FILE
fi

if [[ -f $REQUIREMENTS ]]; then
    echo "[INFO] Running requirements.sh..." | tee -a $LOG_FILE
    bash $REQUIREMENTS
else
    echo "[ERROR] requirements.sh not found!" | tee -a $LOG_FILE
fi

if [[ -f $SCRIPT_A ]]; then
    echo "[INFO] Running script_A.sh..." | tee -a $LOG_FILE
    bash $SCRIPT_A
else
    echo "[ERROR] script_A.sh not found!" | tee -a $LOG_FILE
fi

echo "[INFO] All scripts executed successfully." | tee -a $LOG_FILE
