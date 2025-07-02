# Ansible Playbook for Ubuntu Server Setup (Roles-Based)

This Ansible playbook uses a roles-based architecture to automate the installation and configuration of Apache2, MySQL, Docker, and manages Docker containers with ephemeral storage on Ubuntu servers. **It supports both localhost and remote server deployment.**

## 🏗️ Architecture

The playbook is organized using Ansible roles for better maintainability and reusability:

```
Configuration File/
├── ansible.cfg              # Ansible configuration
├── hosts                    # Inventory file
├── setup-hosts.sh           # Interactive setup script
├── site.yml                 # Main playbook (uses roles)
├── cleanup-roles.yml        # Cleanup playbook
├── requirements.yml         # Ansible collections
├── templates/               # Global templates
│   └── deployment-summary.j2
├── roles/                   # Ansible roles
│   ├── common/              # Common tasks and packages
│   │   ├── tasks/main.yml
│   │   └── defaults/main.yml
│   ├── apache2/             # Apache2 web server
│   │   ├── tasks/main.yml
│   │   ├── handlers/main.yml
│   │   ├── defaults/main.yml
│   │   └── templates/
│   │       ├── apache2-vhost.conf.j2
│   │       └── apache2-custom.conf.j2
│   ├── mysql/               # MySQL database
│   │   ├── tasks/main.yml
│   │   ├── handlers/main.yml
│   │   ├── defaults/main.yml
│   │   └── templates/
│   │       └── mysql.cnf.j2
│   └── docker/              # Docker and containers
│       ├── tasks/main.yml
│       ├── handlers/main.yml
│       └── defaults/main.yml
└── README.md               # This file
```

## 📋 Prerequisites

### For Localhost Deployment:
1. **Ubuntu System**: Ubuntu 18.04+ (or compatible Linux distribution)
2. **Ansible**: Installed on the same machine (version 2.9+)
3. **Sudo Access**: User must have sudo privileges

### For Remote Server Deployment:
1. **Ansible Control Node**: A machine with Ansible installed (version 2.9+)
2. **Target Ubuntu Server**: Ubuntu 18.04+ with SSH access
3. **SSH Key Authentication**: Set up SSH key-based authentication to the target server

## 🚀 Quick Setup

### Option 1: Interactive Setup (Recommended)
```bash
# Run the interactive setup script
./setup-hosts.sh

# Follow the prompts to configure for localhost or remote server
# Then run the playbook
ansible-playbook site.yml
```

### Option 2: Manual Configuration

#### For Localhost Deployment:
Edit the `hosts` file:
```ini
[webservers]
localhost ansible_connection=local ansible_user=ubuntu

[all:vars]
ansible_python_interpreter=/usr/bin/python3
```

#### For Remote Server Deployment:
Edit the `hosts` file:
```ini
[webservers]
ubuntu-server ansible_host=YOUR_SERVER_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

[all:vars]
ansible_python_interpreter=/usr/bin/python3
```

## 🎯 Usage

### Install Ansible Collections
```bash
ansible-galaxy collection install -r requirements.yml
```

### Run the Main Playbook
```bash
# Test connection first
ansible webservers -m ping

# Run the main playbook
ansible-playbook site.yml

# Run with verbose output
ansible-playbook site.yml -v

# Run with extra variables
ansible-playbook site.yml -e "docker_image=louislam/uptime-kuma:1.22.0"
```

### Run Individual Roles
```bash
# Run only Apache2 role
ansible-playbook site.yml --tags apache2

# Run only MySQL role
ansible-playbook site.yml --tags mysql

# Run only Docker role
ansible-playbook site.yml --tags docker
```

### Cleanup
```bash
ansible-playbook cleanup-roles.yml
```

## ⚙️ Configuration

### Role-Specific Variables

Each role has its own configuration in `roles/{role}/defaults/main.yml`:

#### Common Role
```yaml
ephemeral_volume_path: "/tmp/ephemeral-data"
common_user: "{{ ansible_user | default('ubuntu') }}"
is_localhost: "{{ ansible_connection == 'local' }}"
```

#### Apache2 Role
```yaml
apache2_web_root: "/var/www/html"
apache2_server_name: "{{ inventory_hostname | default('localhost') }}"
apache2_server_admin: "webmaster@{{ inventory_hostname | default('localhost') }}"
apache2_port: 80
apache2_security_headers: true
apache2_compression: true
apache2_caching: true
```

#### MySQL Role
```yaml
mysql_database: "webapp"
mysql_user: "webapp_user"
mysql_bind_address: "127.0.0.1"
mysql_skip_networking: false
```

#### Docker Role
```yaml
docker_image: "louislam/uptime-kuma:latest"
docker_container_name: "uptime-kuma"
docker_host_port: "3001"
docker_container_port: "3001"
docker_network_name: "web-network"
docker_restart_policy: "unless-stopped"
```

### Global Variables

Override variables in the main playbook (`site.yml`):

```yaml
vars:
  ephemeral_volume_path: "/tmp/ephemeral-data"
  apache2_server_name: "{{ inventory_hostname | default('localhost') }}"
  mysql_database: "webapp"
  docker_image: "louislam/uptime-kuma:latest"
```

## 🔧 What Gets Installed

### 1. Common Role
- Updates apt cache
- Installs common packages (curl, wget, etc.)
- Creates ephemeral storage directory
- Sets up basic system configuration

### 2. Apache2 Role
- Installs Apache2 web server
- Enables required modules (rewrite, headers, expires, deflate, proxy)
- Configures virtual host with reverse proxy to uptime-kuma
- Sets up compression and caching
- Runs on port 80

### 3. MySQL Role
- Installs MySQL Server and Client
- Secures installation with auto-generated root password
- Creates database and application user
- Configures basic MySQL settings
- Runs on port 3306

### 4. Docker Role
- Installs Docker CE from official repository
- Adds user to docker group
- Creates Docker network
- Pulls uptime-kuma image
- Creates container with ephemeral storage volume
- Maps container port 3001 to host port 3001
- Sets restart policy

## 🔍 Verification

After running the playbook, verify the installation:

```bash
# Check service status
sudo systemctl status apache2
sudo systemctl status mysql
sudo systemctl status docker

# List running containers
docker ps

# Check ephemeral storage
ls -la /tmp/ephemeral-data/

# Test web access
curl http://localhost:80
curl http://localhost:3001

# Test MySQL connection
mysql -u webapp_user -p webapp
```

## 🛡️ Security Features

- **Apache2**: Security headers, compression, caching, reverse proxy
- **MySQL**: Secure installation, auto-generated passwords, restricted access
- **Docker**: Limited privileges, proper volume permissions
- **Ephemeral Storage**: Proper file permissions and ownership

## 🔄 Role Dependencies

The roles are designed to be independent but follow this execution order:
1. `common` - Basic system setup
2. `apache2` - Web server installation
3. `mysql` - Database installation
4. `docker` - Container platform

## 🐛 Troubleshooting

### Common Issues

1. **SSH Connection Failed** (Remote only)
   - Verify SSH key authentication
   - Check firewall settings
   - Ensure target server is accessible

2. **Permission Denied**
   - Ensure target user has sudo privileges
   - Check file permissions on SSH key (remote)

3. **Docker Installation Issues**
   - Verify Ubuntu version compatibility
   - Check internet connectivity for Docker repository

4. **MySQL Installation Issues**
   - Ensure sufficient disk space
   - Check if MySQL is already installed

### Role-Specific Logs

```bash
# Apache2 logs
sudo tail -f /var/log/apache2/error.log

# MySQL logs
sudo tail -f /var/log/mysql/error.log

# Docker logs
docker logs uptime-kuma
```

## 📊 Monitoring

The playbook includes connectivity tests and creates summary files:

- Deployment summary in ephemeral storage
- Service status checks
- Connectivity tests for web services
- MySQL test data insertion

## 🔄 Updating

To update existing installations:

```bash
# Run the playbook again (idempotent)
ansible-playbook site.yml

# Force updates
ansible-playbook site.yml --force-handlers
```

## 📝 Best Practices

1. **Use Tags**: Run specific roles when needed
2. **Version Control**: Keep playbooks in version control
3. **Testing**: Test in staging environment first
4. **Backup**: Backup before major changes
5. **Documentation**: Update variables and configurations

## 🤝 Contributing

To extend the playbook:

1. Add new roles in `roles/` directory
2. Update `site.yml` to include new roles
3. Add role-specific variables in `defaults/main.yml`
4. Update documentation

## 📞 Support

For issues or questions:
1. Check the troubleshooting section
2. Review Ansible logs with `-v` flag
3. Verify all prerequisites are met
4. Ensure target server meets minimum requirements 