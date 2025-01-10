#!/bin/bash
# Setup script for Intrusion Detection Script

# Update package repositories
sudo apt update

# Install required tools
sudo apt install -y tripwire chkrootkit diffutils
