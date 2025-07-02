# System Monitoring and MySQL Backup

Simple automation scripts for system monitoring and MySQL backup.

## Quick Start

### 1. Make Scripts Executable
```bash
chmod +x system_monitor.sh mysql_backup.sh setup_cron.sh
```

### 2. Configure MySQL Backup
Edit `mysql_backup.sh` and set your credentials:
```bash
SRC_USER="your_username"
SRC_PASSWORD="your_password"
SRC_HOST="your_host"
SRC_DB="your_database"
```

### 3. Setup Automated Cron Jobs
```bash
sudo ./setup_cron.sh
```

### 4. Test Scripts
```bash
# Test system monitoring
./system_monitor.sh

# Test MySQL backup
./mysql_backup.sh
```

## What Each Script Does

- **`system_monitor.sh`** - Shows CPU, memory, disk usage and top processes
- **`mysql_backup.sh`** - Backs up MySQL database with compression
- **`setup_cron.sh`** - Sets up automated cron jobs for monitoring and backup

## Cron Schedule
- System monitoring: Every 5 minutes
- Daily system report: 6:00 AM
- Daily MySQL backup: 2:00 AM
- Weekly full backup: Sunday 1:00 AM

## Log Files
- System monitor: `/var/log/system_monitor.log`
- MySQL backup: `/var/log/mysql_backup.log`
- Reports: `/tmp/system_monitor_report_*.txt` 