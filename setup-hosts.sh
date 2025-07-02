#!/bin/bash

# Setup script for Ansible hosts configuration
echo "========================================"
echo "Ansible Hosts Configuration Setup"
echo "========================================"
echo ""

echo "Choose your deployment target:"
echo "1) Localhost (run on this machine)"
echo "2) Remote Ubuntu server"
echo "3) View current configuration"
echo ""

read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        echo ""
        echo "Configuring for localhost deployment..."
        # Backup current hosts file
        cp hosts hosts.backup.$(date +%Y%m%d_%H%M%S)
        
        # Create localhost configuration
        cat > hosts << 'EOF'
[webservers]
# Localhost configuration
localhost ansible_connection=local ansible_user=ubuntu

[all:vars]
ansible_python_interpreter=/usr/bin/python3
EOF
        echo "✅ Hosts file configured for localhost deployment"
        echo "   You can now run: ansible-playbook site.yml"
        ;;
    2)
        echo ""
        echo "Configuring for remote server deployment..."
        echo "Please provide the following information:"
        echo ""
        read -p "Enter server IP address: " server_ip
        read -p "Enter SSH username (default: ubuntu): " ssh_user
        ssh_user=${ssh_user:-ubuntu}
        read -p "Enter path to SSH private key (default: ~/.ssh/id_rsa): " ssh_key
        ssh_key=${ssh_key:-~/.ssh/id_rsa}
        
        # Backup current hosts file
        cp hosts hosts.backup.$(date +%Y%m%d_%H%M%S)
        
        # Create remote server configuration
        cat > hosts << EOF
[webservers]
# Remote server configuration
ubuntu-server ansible_host=${server_ip} ansible_user=${ssh_user} ansible_ssh_private_key_file=${ssh_key}

[all:vars]
ansible_python_interpreter=/usr/bin/python3
EOF
        echo "✅ Hosts file configured for remote server deployment"
        echo "   Server IP: ${server_ip}"
        echo "   SSH User: ${ssh_user}"
        echo "   SSH Key: ${ssh_key}"
        echo "   You can now run: ansible-playbook site.yml"
        ;;
    3)
        echo ""
        echo "Current hosts configuration:"
        echo "========================================"
        cat hosts
        echo "========================================"
        ;;
    *)
        echo "❌ Invalid choice. Please run the script again."
        exit 1
        ;;
esac

echo ""
echo "========================================"
echo "Setup complete!"
echo "========================================" 