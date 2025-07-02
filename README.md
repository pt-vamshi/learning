# Task - Complete DevOps Infrastructure Project

This repository contains a comprehensive DevOps infrastructure project with multiple components for server automation, containerization, cloud infrastructure, and system monitoring.

## 📁 Project Structure

```
Task/
├── Configuration File/          # Ansible automation for server setup
├── Docker-Docker_compose/       # Containerized Python application
├── Infrastructure-as-Code/      # AWS serverless media streaming app
└── System Monitoring/           # System monitoring and backup scripts
```

## 🏗️ Architecture Overview

This project demonstrates a complete DevOps pipeline with:

1. **Server Automation** (Ansible) - Automated server provisioning and configuration
2. **Containerization** (Docker) - Containerized application deployment
3. **Cloud Infrastructure** (Terraform) - Serverless AWS infrastructure
4. **Monitoring & Backup** (Bash Scripts) - System monitoring and database backup automation

## 📂 Detailed Component Breakdown

### 1. Configuration File/ - Ansible Server Automation

**Purpose**: Automated server setup using Ansible roles for Apache2, MySQL, and Docker deployment.

**Key Features**:
- ✅ Roles-based architecture for maintainability
- ✅ Supports both localhost and remote server deployment
- ✅ Interactive setup script (`setup-hosts.sh`)
- ✅ Automated installation of Apache2, MySQL, Docker
- ✅ Ephemeral storage management
- ✅ Security hardening and configuration

**Technologies**: Ansible, Ubuntu, Apache2, MySQL, Docker

**Quick Start**:
```bash
cd "Configuration File"
./setup-hosts.sh
ansible-playbook site.yml
```

**Documentation**: [Configuration File/README.md](Configuration%20File/README.md)

---

### 2. Docker-Docker_compose/ - Containerized Application

**Purpose**: Python Flask application containerized with Docker and Nginx reverse proxy.

**Key Features**:
- ✅ Hot reload development environment
- ✅ Nginx reverse proxy for production-ready setup
- ✅ Volume mounting for real-time development
- ✅ Health checks and monitoring
- ✅ Single container deployment with Docker Compose

**Technologies**: Docker, Docker Compose, Python Flask, Nginx

**Quick Start**:
```bash
cd Docker-Docker_compose
docker-compose up --build
```

**Access**: http://localhost (via Nginx) or http://localhost:8000 (direct Flask app)

**Documentation**: [Docker-Docker_compose/README.md](Docker-Docker_compose/README.md)

---

### 3. Infrastructure-as-Code/ - AWS Serverless Media Streaming

**Purpose**: Serverless media streaming application on AWS using Terraform.

**Key Features**:
- ✅ Serverless architecture (S3, CloudFront, Lambda, API Gateway)
- ✅ WAF protection for security
- ✅ CDN distribution for global performance
- ✅ Private S3 bucket with OAI access
- ✅ Automatic video listing via Lambda function

**Technologies**: Terraform, AWS S3, CloudFront, Lambda, API Gateway, WAF

**Quick Start**:
```bash
cd Infrastructure-as-Code
zip lambda_list_videos.zip lambda_list_videos.py
terraform init
terraform apply
```

**Documentation**: [Infrastructure-as-Code/README.md](Infrastructure-as-Code/README.md)

---

### 4. System Monitoring/ - Monitoring & Backup Automation

**Purpose**: Automated system monitoring and MySQL backup scripts.

**Key Features**:
- ✅ Real-time system monitoring (CPU, memory, disk usage)
- ✅ Automated MySQL database backup with compression
- ✅ Cron job automation for scheduled tasks
- ✅ Logging and reporting capabilities
- ✅ Configurable backup schedules

**Technologies**: Bash Scripts, Cron, MySQL

**Quick Start**:
```bash
cd "System Monitoring"
chmod +x *.sh
sudo ./setup_cron.sh
```

**Documentation**: [System Monitoring/README.md](System%20Monitoring/README.md)

---

## 🚀 Getting Started

### Prerequisites

1. **For Ansible (Configuration File/)**:
   - Ubuntu 18.04+ or compatible Linux
   - Ansible 2.9+
   - SSH access (for remote deployment)

2. **For Docker (Docker-Docker_compose/)**:
   - Docker and Docker Compose
   - Port 80 and 8000 available

3. **For Terraform (Infrastructure-as-Code/)**:
   - Terraform CLI
   - AWS CLI configured
   - AWS account with appropriate permissions

4. **For Monitoring (System Monitoring/)**:
   - Linux system with bash
   - MySQL server (for backup functionality)
   - Sudo privileges for cron setup

### Quick Demo

1. **Start with Docker application** (easiest to test):
   ```bash
   cd Docker-Docker_compose
   docker-compose up --build
   ```

2. **Deploy server automation**:
   ```bash
   cd "Configuration File"
   ./setup-hosts.sh
   ansible-playbook site.yml
   ```

3. **Deploy cloud infrastructure**:
   ```bash
   cd Infrastructure-as-Code
   terraform init && terraform apply
   ```

4. **Setup monitoring**:
   ```bash
   cd "System Monitoring"
   sudo ./setup_cron.sh
   ```

## 🔧 Configuration

Each component has its own configuration files and documentation:

- **Ansible**: `Configuration File/group_vars/`, `Configuration File/roles/*/defaults/`
- **Docker**: `Docker-Docker_compose/docker-compose.yml`, `Docker-Docker_compose/Dockerfile`
- **Terraform**: `Infrastructure-as-Code/main.tf`, `Infrastructure-as-Code/variables.tf`
- **Monitoring**: `System Monitoring/*.sh` scripts

## 📊 Monitoring & Logs

- **System Monitoring**: `/var/log/system_monitor.log`
- **MySQL Backup**: `/var/log/mysql_backup.log`
- **Ansible**: Check with `ansible-playbook site.yml -v`
- **Docker**: `docker-compose logs`
- **Terraform**: `terraform plan` and `terraform apply`

## 🔒 Security Features

- **WAF Protection**: AWS WAF on CloudFront distribution
- **Private S3**: OAI-only access to S3 bucket
- **Secure MySQL**: Auto-generated passwords and restricted access
- **Docker Security**: Non-root user in containers
- **Ansible Security**: SSH key authentication and sudo privileges

## 🧪 Testing

Each component includes testing capabilities:

- **Ansible**: `ansible webservers -m ping`
- **Docker**: Health checks and volume mounting for development
- **Terraform**: `terraform plan` and `terraform validate`
- **Monitoring**: Direct script execution for testing

## 📈 Scalability

- **Horizontal Scaling**: Docker Compose can be extended with multiple containers
- **Cloud Scaling**: AWS Auto Scaling Groups can be added to Terraform
- **Load Balancing**: Nginx reverse proxy and CloudFront CDN
- **Database Scaling**: MySQL replication can be added to Ansible roles

## 🤝 Contributing

1. Each component is self-contained with its own README
2. Follow the existing patterns in each folder
3. Test changes in the respective component before integration
4. Update documentation when adding new features

## 📝 License

This project is for educational and demonstration purposes. Each component may have its own licensing requirements.

## 🆘 Troubleshooting

### Common Issues

1. **Ansible Connection Issues**: Check SSH keys and inventory file
2. **Docker Port Conflicts**: Ensure ports 80 and 8000 are available
3. **Terraform AWS Errors**: Verify AWS credentials and permissions
4. **Monitoring Scripts**: Check file permissions and MySQL credentials

### Getting Help

- Check individual component README files for specific troubleshooting
- Review logs in `/var/log/` for system monitoring issues
- Use `terraform plan` to debug infrastructure issues
- Check Docker logs with `docker-compose logs`

---

**Note**: This project demonstrates various DevOps practices and can be used as a learning resource or starting point for production deployments. Always review and customize configurations for your specific use case. 