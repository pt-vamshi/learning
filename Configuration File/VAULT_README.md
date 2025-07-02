# Ansible Vault Setup Guide

This guide explains how to use Ansible Vault for secure password management in this playbook.

## 🔐 What is Ansible Vault?

Ansible Vault is a feature that allows you to encrypt sensitive data such as passwords, API keys, and other secrets. This ensures that sensitive information is not stored in plain text in your playbooks.

## 📁 Vault Files Structure

```
Configuration File/
├── group_vars/
│   └── all/
│       ├── vault.yml          # Encrypted sensitive variables
│       └── vars.yml           # Non-sensitive variables
├── .vault_pass                # Vault password file (not in git)
└── VAULT_README.md           # This file
```

## 🚀 Quick Setup

### 1. Set Your Vault Password

Edit the `.vault_pass` file and replace `your_vault_password_here` with your actual vault password:

```bash
# Edit the vault password file
nano .vault_pass
```

### 2. Set Environment Variable (Optional)

For easier access, you can set an environment variable:

```bash
export ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass
```

### 3. Run the Playbook

```bash
# Method 1: Using environment variable
ansible-playbook site.yml

# Method 2: Using --vault-password-file
ansible-playbook site.yml --vault-password-file .vault_pass

# Method 3: Using --ask-vault-pass (prompts for password)
ansible-playbook site.yml --ask-vault-pass
```

## 🔧 Managing Vault Files

### View Encrypted File

```bash
ansible-vault view group_vars/all/vault.yml
```

### Edit Encrypted File

```bash
ansible-vault edit group_vars/all/vault.yml
```

### Create New Encrypted File

```bash
ansible-vault create group_vars/all/new_vault.yml
```

### Encrypt Existing File

```bash
ansible-vault encrypt group_vars/all/sensitive_file.yml
```

### Decrypt File (for editing)

```bash
ansible-vault decrypt group_vars/all/vault.yml
```

## 📋 Variables in Vault

The `group_vars/all/vault.yml` file contains:

```yaml
# MySQL root password (auto-generated secure password)
mysql_root_password: "{{ lookup('password', '/dev/null length=32 chars=ascii_letters,digits') }}"

# MySQL application user password (auto-generated secure password)
mysql_user_password: "{{ lookup('password', '/dev/null length=16 chars=ascii_letters,digits') }}"

# Docker registry credentials (if needed)
# docker_registry_username: ""
# docker_registry_password: ""

# SSH private key passphrase (if needed)
# ssh_key_passphrase: ""
```

## 🔒 Security Best Practices

1. **Never commit `.vault_pass` to version control**
2. **Use strong, unique passwords for vault**
3. **Rotate vault passwords regularly**
4. **Limit access to vault files**
5. **Use environment variables in production**

## 🛠️ Troubleshooting

### Vault Password Issues

If you get vault password errors:

```bash
# Check if vault password file exists
ls -la .vault_pass

# Verify vault password file permissions
chmod 600 .vault_pass

# Test vault access
ansible-vault view group_vars/all/vault.yml
```

### Common Errors

1. **"Vault password file not found"**
   - Ensure `.vault_pass` file exists
   - Check file permissions

2. **"Incorrect vault password"**
   - Verify password in `.vault_pass`
   - Try `--ask-vault-pass` to enter manually

3. **"Permission denied"**
   - Check file permissions: `chmod 600 .vault_pass`

## 📝 Example Usage

```bash
# 1. Set up vault password
echo "my_secure_vault_password" > .vault_pass
chmod 600 .vault_pass

# 2. Set environment variable
export ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass

# 3. Run playbook
ansible-playbook site.yml

# 4. View passwords (if needed)
ansible-vault view group_vars/all/vault.yml
```

## 🔄 Updating Passwords

To update passwords in vault:

```bash
# Edit the vault file
ansible-vault edit group_vars/all/vault.yml

# Or view current passwords
ansible-vault view group_vars/all/vault.yml
```

## 📞 Support

For vault-related issues:
1. Check this guide
2. Review Ansible Vault documentation
3. Verify file permissions and passwords
4. Test vault access before running playbook 