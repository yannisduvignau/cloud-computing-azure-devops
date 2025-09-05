#!/bin/bash
# Automatic generation and configuration of an Ed25519 SSH key with optional parameters

set -e

# Default values
COMMENT="cloud_tp1"
KEY_PATH="$HOME/.ssh/id_ed25519"
SERVER=""

# Usage/help
usage() {
    echo "Usage: $0 [-c comment] [-f key_path] [-s user@server]"
    echo "  -c   Comment to embed in the key (default: $COMMENT)"
    echo "  -f   Key path (default: $KEY_PATH)"
    echo "  -s   Optional server (format: user@host) to copy the public key via ssh-copy-id"
    exit 1
}

# Parse parameters
while getopts "e:f:s:h" opt; do
  case $opt in
    e) COMMENT="$OPTARG" ;;
    f) KEY_PATH="$OPTARG" ;;
    s) SERVER="$OPTARG" ;;
    h) usage ;;
    *) usage ;;
  esac
done

# Ensure ~/.ssh exists
mkdir -p ~/.ssh

echo "Generating a new Ed25519 SSH key pair..."
ssh-keygen -t ed25519 -a 100 -o -C "$COMMENT" -f "$KEY_PATH"

echo "Starting the SSH agent..."
eval "$(ssh-agent -s)"

echo "Adding the key to the SSH agent..."
ssh-add "$KEY_PATH"

echo "Updating ~/.ssh/config..."
if ! grep -q "IdentityFile $KEY_PATH" ~/.ssh/config 2>/dev/null; then
cat >> ~/.ssh/config <<EOF

Host *
  AddKeysToAgent yes
  IdentityFile $KEY_PATH
EOF
chmod 600 ~/.ssh/config
fi

echo "SSH public key generated:"
cat "$KEY_PATH.pub"

# Optional: install on remote server
# if [[ -n "$SERVER" ]]; then
#     echo "📡 Copying public key to $SERVER..."
#     ssh-copy-id -i "$KEY_PATH.pub" "$SERVER"
#     echo "✅ Key installed on $SERVER"
# else
#     echo "👉 To copy your key to a server, run:"
#     echo "   ssh-copy-id -i $KEY_PATH.pub user@server"
# fi
