#!/bin/bash

# System Monitor Script
# Simple CPU and Memory monitoring with top processes

# Configuration
LOG_FILE="/var/log/system_monitor.log"
ALERT_THRESHOLD_CPU=80
ALERT_THRESHOLD_MEMORY=85
MAX_PROCESSES=10

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Step 1: Get system information
echo -e "${BLUE}=== SYSTEM INFORMATION ===${NC}"
echo "Hostname: $(hostname)"
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime -p)"
echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
echo ""

# Step 2: Check CPU usage
echo -e "${BLUE}=== CPU USAGE ===${NC}"
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
CPU_CORES=$(nproc)
CPU_MODEL=$(grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | xargs)

echo "CPU Model: $CPU_MODEL"
echo "CPU Cores: $CPU_CORES"
echo "Current CPU Usage: ${CPU_USAGE}%"

if (( $(echo "$CPU_USAGE > $ALERT_THRESHOLD_CPU" | bc -l) )); then
    echo -e "${RED}WARNING: CPU usage is above ${ALERT_THRESHOLD_CPU}%${NC}"
    log_message "WARNING: High CPU usage detected: ${CPU_USAGE}%"
else
    echo -e "${GREEN}CPU usage is normal${NC}"
fi
echo ""

# Step 3: Check memory usage
echo -e "${BLUE}=== MEMORY USAGE ===${NC}"
TOTAL_MEM=$(free -m | awk 'NR==2{printf "%.2f", $2/1024}')
USED_MEM=$(free -m | awk 'NR==2{printf "%.2f", $3/1024}')
FREE_MEM=$(free -m | awk 'NR==2{printf "%.2f", $4/1024}')
MEM_USAGE_PERCENT=$(free | awk 'NR==2{printf "%.1f", $3*100/$2}')

echo "Total Memory: ${TOTAL_MEM} GB"
echo "Used Memory: ${USED_MEM} GB"
echo "Free Memory: ${FREE_MEM} GB"
echo "Memory Usage: ${MEM_USAGE_PERCENT}%"

if (( $(echo "$MEM_USAGE_PERCENT > $ALERT_THRESHOLD_MEMORY" | bc -l) )); then
    echo -e "${RED}WARNING: Memory usage is above ${ALERT_THRESHOLD_MEMORY}%${NC}"
    log_message "WARNING: High memory usage detected: ${MEM_USAGE_PERCENT}%"
else
    echo -e "${GREEN}Memory usage is normal${NC}"
fi
echo ""

# Step 4: Get top CPU consuming processes
echo -e "${YELLOW}=== TOP CPU CONSUMING PROCESSES ===${NC}"
echo "PID\tCPU%\tMEM%\tCOMMAND"
echo "----------------------------------------"
ps aux --sort=-%cpu | head -$((MAX_PROCESSES + 1)) | tail -$MAX_PROCESSES | \
awk '{printf "%-8s %-8s %-8s %s\n", $2, $3, $4, $11}' | head -$MAX_PROCESSES
echo ""

# Step 5: Get top memory consuming processes
echo -e "${YELLOW}=== TOP MEMORY CONSUMING PROCESSES ===${NC}"
echo "PID\tCPU%\tMEM%\tCOMMAND"
echo "----------------------------------------"
ps aux --sort=-%mem | head -$((MAX_PROCESSES + 1)) | tail -$MAX_PROCESSES | \
awk '{printf "%-8s %-8s %-8s %s\n", $2, $3, $4, $11}' | head -$MAX_PROCESSES
echo ""

# Step 6: Check disk usage
echo -e "${GREEN}=== DISK USAGE ===${NC}"
df -h | grep -E '^/dev/' | while read line; do
    FILESYSTEM=$(echo $line | awk '{print $1}')
    SIZE=$(echo $line | awk '{print $2}')
    USED=$(echo $line | awk '{print $3}')
    AVAIL=$(echo $line | awk '{print $4}')
    USE_PERCENT=$(echo $line | awk '{print $5}' | sed 's/%//')
    MOUNT=$(echo $line | awk '{print $6}')
    
    echo "Filesystem: $FILESYSTEM"
    echo "  Mount Point: $MOUNT"
    echo "  Size: $SIZE, Used: $USED, Available: $AVAIL, Usage: $USE_PERCENT%"
    
    if [ "$USE_PERCENT" -gt 90 ]; then
        echo -e "  ${RED}WARNING: Disk usage is above 90%${NC}"
        log_message "WARNING: High disk usage on $MOUNT: ${USE_PERCENT}%"
    fi
    echo ""
done

# Step 7: Generate report
REPORT_FILE="/tmp/system_monitor_report_$(date +%Y%m%d_%H%M%S).txt"
{
    echo "=== SYSTEM MONITORING REPORT ==="
    echo "Generated: $(date)"
    echo "Hostname: $(hostname)"
    echo ""
    echo "=== CPU USAGE ==="
    top -bn1 | grep "Cpu(s)" | awk '{print "CPU Usage: " $2}'
    echo ""
    echo "=== MEMORY USAGE ==="
    free -h | grep -E '^Mem|^Swap'
    echo ""
    echo "=== TOP PROCESSES ==="
    ps aux --sort=-%cpu | head -6
    echo ""
    echo "=== DISK USAGE ==="
    df -h
} > "$REPORT_FILE"

echo -e "${GREEN}Report generated: $REPORT_FILE${NC}"
log_message "System monitoring completed - Report: $REPORT_FILE"
echo -e "${GREEN}System monitoring completed successfully!${NC}" 