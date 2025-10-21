# 🤖 Claude Code CLI Container (Unofficial)

Fork of https://github.com/Zeeno-atl/claude-code. Documentation down there.

An unofficial containerized version of the Claude Code CLI, allowing you to interact with Claude's powerful AI assistance for coding tasks in any project. This is not an official Anthropic product. All the code is written by the Claude-code.

## Usage
```
claude(){ docker run --rm -it \
	-v "$(pwd):/app" \
	-v ~/.npm-cache:/npm-cache \
	-e CONTAINER_USER_ID=$(id -u) \
	-e CONTAINER_GROUP_ID=$(id -g) \
	claude
}
```

## settings.json

Just an example:

```
{
	"permissions": {
		"deny": [
			"Bash(true:*)"
		]
	},
	"env": {
		"CLAUDE_CODE_ENABLE_TELEMETRY": "0"
	},
	"prompt.viMode": true,
	"prompt.viModeIndicator": true,
	"security": {
		"trust": {
			"autoTrust": true,
			"showTrustPrompts": false
		}
	}
}
```
