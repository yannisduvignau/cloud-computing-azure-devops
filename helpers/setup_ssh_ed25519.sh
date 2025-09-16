#!/bin/bash
# Automatic generation and configuration of an Ed25519 SSH key with optional parameters

# Stop script on any error, on unset variables, and on pipe failures.
set -euo pipefail

# --- Default values ---
TP_NUMBER="1"
COMMENT="cloud_tp$TP_NUMBER"
KEY_PATH="$HOME/.ssh/id_ed25519"
SERVER=""

# --- Usage/help function ---
usage() {
    echo "Usage: $0 [-n tp_number] [-f key_path] [-s user@server]"
    echo "  -n   Comment to embed in the key (default: $TP_NUMBER)"
    echo "  -f   Key path (default: $KEY_PATH)"
    echo "  -s   Optional server (format: user@host) to copy the public key via ssh-copy-id"
    exit 1
}

# --- Parse parameters ---
while getopts "c:f:s:h" opt; do
  case $opt in
    c) TP_NUMBER="$OPTARG" ;;
    f) KEY_PATH="$OPTARG" ;;
    s) SERVER="$OPTARG" ;;
    h) usage ;;
    *) usage ;;
  esac
done

# --- Main logic ---

# Ensure ~/.ssh directory exists with correct permissions
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Check if the key already exists to prevent accidental overwrite
if [ -f "$KEY_PATH" ]; then
    read -p "⚠️  Key '$KEY_PATH' already exists. Overwrite? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted by user."
        exit 1
    fi
fi

echo "🔐 Generating a new Ed25519 SSH key pair (you will be prompted for a passphrase)..."
# Generate the key, prompting for a passphrase interactively.
ssh-keygen -t ed25519 -a 100 -o -C "$COMMENT" -f "$KEY_PATH"

echo "⚙️  Starting the SSH agent..."
eval "$(ssh-agent -s)"

echo "➕ Adding the key to the SSH agent..."
ssh-add "$KEY_PATH"

echo "📝 Updating ~/.ssh/config..."
# Ensure the config file exists with the right permissions
touch ~/.ssh/config
chmod 600 ~/.ssh/config

# Add config entries idempotently to avoid duplicates
if ! grep -q "Host \*" ~/.ssh/config; then
  # If no "Host *" block exists, create one with our settings.
  {
    echo ""
    echo "Host *"
    echo "  AddKeysToAgent yes"
    echo "  IdentityFile $KEY_PATH"
  } >> ~/.ssh/config
elif ! grep -q "IdentityFile $KEY_PATH" ~/.ssh/config; then
  # If "Host *" exists but our key is not listed, add it.
  # This adds the line after the "Host *" line.
  sed -i.bak "/Host \\*/a \\  IdentityFile $KEY_PATH" ~/.ssh/config
fi

echo "🔑 Your SSH public key:"
cat "$KEY_PATH.pub"

# Optional: install on remote server
if [[ -n "$SERVER" ]]; then
    echo "📡 Copying public key to $SERVER..."
    ssh-copy-id -i "$KEY_PATH.pub" "$SERVER"
    echo "✅ Key installed on $SERVER"
else
    echo "👉 To copy your key to a server, run:"
    echo "   ssh-copy-id -i \"$KEY_PATH.pub\" azureuser@mon-vm-toto.uksouth.cloudapp.azure.com"
fi