# Agentic Coding Agent Guide

## Build and Test Commands
- Build Docker image: `make build` (with cache) or `docker build -t claude .`
- Run container: `make run` (current dir) or `make run-dir DIR=/path/to/dir`
- Test workflow: Validate with GitHub Actions workflow `.github/workflows/docker-build.yml`
- No automated tests present - validate functionality by running container

## Code Style Guidelines
- **Language**: Bash scripting for shell scripts
- **Formatting**: 2-space indentation, UNIX line endings (LF)
- **Shebang**: Use `#!/usr/bin/env bash` for portability
- **Error Handling**: Always use `set -e` and `set -o pipefail` at script start
- **Logging**: Use log function with timestamp: `log() { echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"; }`
- **Comments**: Add header comments to scripts explaining purpose, include inline comments for complex logic
- **Naming**: Lowercase filenames with extensions (`.sh`), descriptive variable names in UPPER_SNAKE_CASE for globals
- **Permissions**: Ensure scripts are executable (`chmod +x`)
- **Variables**: Quote all variables to prevent word splitting: `"$VAR"`, use `${VAR}` for clarity
- **Exit Codes**: Proper error handling with meaningful exit codes, check command success before proceeding

## Project Structure
- `Dockerfile`: Debian-based with Node.js/npm, Python3, build tools
- `docker-entrypoint.sh`: Main entrypoint with user/group ID handling
- `docker-entrypoint.d/*.sh`: Initialization scripts executed in order
- `claude-wrapper.sh`: Installs and launches Claude Code CLI
- `Makefile`: Build/run/clean targets with documentation
