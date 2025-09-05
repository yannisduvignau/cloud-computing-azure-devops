#!/bin/bash
# Automatically start SSH agent and add only Ed25519 keys

# Check if SSH agent is already running
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    echo "🚀 Starting SSH agent..."
    eval "$(ssh-agent -s)"
else
    echo "✅ SSH agent already running"
fi

# Add only Ed25519 keys
for key in ~/.ssh/id_ed25519*; do
    if [[ -f "$key" && "$key" != *.pub ]]; then
        ssh-add "$key" 2>/dev/null || true
    fi
done

# List loaded Ed25519 keys
echo "🔑 Ed25519 keys loaded in SSH agent:"
ssh-add -l | grep "ED25519" || echo "No Ed25519 keys loaded."
