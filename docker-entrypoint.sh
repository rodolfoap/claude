#!/usr/bin/env bash
#
# Main entrypoint script for Unofficial Claude Code container
# Executes all initialization scripts and launches the specified command
# This is not an official Anthropic product
#

# Exit immediately if a command exits with a non-zero status
set -e
# Exit if any command in a pipeline fails
set -o pipefail

# Log function for better visibility
log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

log "Starting container initialization"

# Execute all initialization scripts in order
for script in /docker-entrypoint.d/*.sh; do
  if [ -f "$script" ] && [ -x "$script" ]; then
    log "Running initialization script: $script"
    "$script" || {
      log "ERROR: Initialization script $script failed with status $?"
      exit 1
    }
  fi
done

# Get the user ID and group ID from the app directory
# Default to current user if the directory is owned by root (could happen in some Docker setups)
USER_ID=$(stat -c %u /app)
GROUP_ID=$(stat -c %g /app)

# If USER_ID is root (0), and a non-root UID is specified via environment variable, use that instead
if [ "$USER_ID" = "0" ] && [ -n "$CONTAINER_USER_ID" ] && [ "$CONTAINER_USER_ID" != "0" ]; then
  USER_ID=$CONTAINER_USER_ID
  # If GROUP_ID is not specified, make it the same as USER_ID
  GROUP_ID=${CONTAINER_GROUP_ID:-$USER_ID}
  log "Using user ID from environment variable: $USER_ID:$GROUP_ID"
fi

log "Running as user ID: ${USER_ID}, group ID: ${GROUP_ID}"

# If we're not root (could happen with custom docker run commands)
if [ "$USER_ID" != "0" ]; then
  # Create group if it doesn't exist
  if ! getent group $GROUP_ID > /dev/null 2>&1; then
    groupadd -g $GROUP_ID appuser
  fi

  # Create user if it doesn't exist
  if ! getent passwd $USER_ID > /dev/null 2>&1; then
    useradd -u $USER_ID -g $GROUP_ID -d /app -s /bin/bash appuser
  fi

  log "Initialization complete, launching command as UID $USER_ID: $@"
  # Use gosu to drop privileges and run the command as the app directory owner
  exec gosu $USER_ID:$GROUP_ID "$@"
else
  log "Initialization complete, launching command as root: $@"
  exec "$@"
fi