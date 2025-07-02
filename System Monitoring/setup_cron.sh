#!/bin/bash

# Setup Cron Jobs Script
# Simple cron job setup for system monitoring and MySQL backup

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_MONITOR_SCRIPT="$SCRIPT_DIR/system_monitor.sh"
MYSQL_BACKUP_SCRIPT="$SCRIPT_DIR/mysql_backup.sh"

# Step 1: Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}ERROR: This script must be run as root${NC}"
    echo "Please run: sudo $0"
    exit 1
fi

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}    CRON JOB SETUP SCRIPT       ${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Step 2: Check if scripts exist and are executable
echo -e "${BLUE}Checking scripts...${NC}"

if [ ! -f "$SYSTEM_MONITOR_SCRIPT" ]; then
    echo -e "${RED}ERROR: System monitor script not found at $SYSTEM_MONITOR_SCRIPT${NC}"
    exit 1
fi

if [ ! -f "$MYSQL_BACKUP_SCRIPT" ]; then
    echo -e "${RED}ERROR: MySQL backup script not found at $MYSQL_BACKUP_SCRIPT${NC}"
    exit 1
fi

chmod +x "$SYSTEM_MONITOR_SCRIPT" "$MYSQL_BACKUP_SCRIPT"
echo -e "${GREEN}✓ Scripts are ready${NC}"
echo ""

# Step 3: Create log directories
echo -e "${BLUE}Creating log directories...${NC}"
mkdir -p /var/log
touch /var/log/system_monitor.log /var/log/mysql_backup.log
chmod 644 /var/log/system_monitor.log /var/log/mysql_backup.log
mkdir -p /var/backups/mysql
chmod 755 /var/backups/mysql
echo -e "${GREEN}✓ Log directories created${NC}"
echo ""

# Step 4: Setup cron jobs
echo -e "${BLUE}Setting up cron jobs...${NC}"

# System monitoring every 5 minutes
(crontab -l 2>/dev/null; echo "*/5 * * * * $SYSTEM_MONITOR_SCRIPT") | crontab -
echo -e "${GREEN}✓ Added system monitoring (every 5 minutes)${NC}"

# Daily system report at 6 AM
(crontab -l 2>/dev/null; echo "0 6 * * * $SYSTEM_MONITOR_SCRIPT") | crontab -
echo -e "${GREEN}✓ Added daily system report (6 AM)${NC}"

# Daily MySQL backup at 2 AM
(crontab -l 2>/dev/null; echo "0 2 * * * $MYSQL_BACKUP_SCRIPT") | crontab -
echo -e "${GREEN}✓ Added daily MySQL backup (2 AM)${NC}"

# Weekly full backup on Sunday at 1 AM
(crontab -l 2>/dev/null; echo "0 1 * * 0 $MYSQL_BACKUP_SCRIPT --full") | crontab -
echo -e "${GREEN}✓ Added weekly full backup (Sunday 1 AM)${NC}"

echo -e "${GREEN}✓ All cron jobs configured${NC}"
echo ""

# Step 5: Show current cron jobs
echo -e "${BLUE}Current monitoring and backup cron jobs:${NC}"
echo "----------------------------------------"
crontab -l 2>/dev/null | grep -E "(system_monitor|mysql_backup)" || echo "No monitoring/backup cron jobs found"
echo "----------------------------------------"
echo ""

# Step 6: Test scripts
echo -e "${BLUE}Testing scripts...${NC}"

# Test system monitor script (timeout to avoid hanging)
if timeout 30s "$SYSTEM_MONITOR_SCRIPT" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ System monitor script test passed${NC}"
else
    echo -e "${YELLOW}⚠ System monitor script test had issues (check manually)${NC}"
fi

# Test MySQL backup script (help only)
if "$MYSQL_BACKUP_SCRIPT" --help > /dev/null 2>&1; then
    echo -e "${GREEN}✓ MySQL backup script test passed${NC}"
else
    echo -e "${YELLOW}⚠ MySQL backup script test had issues (check manually)${NC}"
fi

echo ""
echo -e "${GREEN}✓ Cron job setup completed successfully!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Test system monitoring: $SYSTEM_MONITOR_SCRIPT"
echo "2. Test MySQL backup: $MYSQL_BACKUP_SCRIPT"
echo "3. Check logs: tail -f /var/log/system_monitor.log"
echo "4. View cron jobs: crontab -l"
echo ""
echo -e "${BLUE}Script completed!${NC}" 