#!/usr/bin/env bash
#
# Unofficial Claude Code Environment Setup
# Sets up directories and prepares the environment for Claude Code CLI
# This is not an official Anthropic product
#

# Exit on errors
set -e
set -o pipefail

# Log function for better visibility
log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

log "Setting up environment for Claude Code CLI..."

# Create directory for npm cache and ensure it's writable
mkdir -p /npm-cache
chmod 777 /npm-cache

# Create directories for npm global packages
mkdir -p /usr/local/lib/node_modules
chmod 777 /usr/local/lib/node_modules

# Make sure bin directory is writable
mkdir -p /usr/local/bin
chmod 777 /usr/local/bin

# Create a directory for user-specific npm packages (outside of /app)
mkdir -p /home/npm-global
chmod 777 /home/npm-global

log "Environment setup complete"