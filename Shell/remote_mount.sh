#!/bin/bash
# remote_mount.sh
# Purpose: Mount remote filesystem via SSHFS with VPN bypass
# Requirements: 
#   - SSHFS installed
#   - Mullvad VPN with mullvad-exclude
#   - SSH access to remote server
#
# Features:
#   - Creates mount directory if not exists
#   - Handles custom SSH ports
#   - Maintains connection with keepalive settings
#   - Bypasses VPN for mount connection
#   - Verifies successful mounting

# Use $HOME for the mount directory
remote_mount_dir="$HOME/remote_mount"

# If no mount directory, create one
if [ ! -d "$remote_mount_dir" ]; then
  mkdir -p "$remote_mount_dir"
  echo "Created remote mount directory: $remote_mount_dir"
fi

server="user@serverip" # Replace with your username and server ip address
port="customport" # Replace with custom ssh port or change to 22 for default
mount_command="sshfs -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3 -p $port $server:/ $remote_mount_dir"

if mountpoint -q "$remote_mount_dir"; then
  echo "Remote mount already exists. Skipping mount."
else
  echo "Mounting remote filesystem (outside VPN)..."

  (
    mullvad-exclude bash -c "$mount_command"
    if [[ $? -eq 0 ]]; then
        echo "Remote filesystem mounted successfully at $remote_mount_dir"
    else
        echo "Error mounting remote filesystem. Check your connection and credentials."
        exit 1
    fi
  )
fi

if mountpoint -q "$remote_mount_dir"; then
  echo "Remote mount verified."
else
  echo "Remote mount failed.  Exiting."
  exit 1
fi


