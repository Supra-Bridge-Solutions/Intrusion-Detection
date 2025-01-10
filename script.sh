#!/bin/bash

CRITICAL_FILES=("/etc/passwd" "/etc/shadow" "/etc/group") # Files to monitor
CHECKSUM_FILE="/var/log/critical_files_checksums.txt"     # Store checksums
LOG_FILE="/var/log/intrusion_detection.log"              # Log file
TRIPWIRE_CMD="tripwire --check"                          # Command to run Tripwire
CHKROOTKIT_CMD="chkrootkit"                              # Command to run chkrootkit
