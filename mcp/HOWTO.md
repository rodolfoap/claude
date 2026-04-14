# How to Write an MCP Tool for Claude Code

This guide shows how to expose a local Python function as a tool that Claude Code can call, using FastMCP over stdio.

---

## Overview

Claude Code reads MCP (Model Context Protocol) server definitions from `.mcp.json` at the project root. Each server is a process that Claude Code launches and communicates with over stdin/stdout using JSON-RPC.

**Two separate systems — do not confuse them:**
- `.vscode/mcp.json` — VS Code's built-in MCP host (for Copilot etc.). Claude Code does NOT read this.
- `.mcp.json` (project root) — Claude Code's MCP config. This is the one that matters.

---

## Step 1 — Set up a Python virtualenv

```bash
python3 -m venv .venv
.venv/bin/pip install mcp
```

The `mcp` package includes `fastmcp`, a high-level wrapper that handles all the JSON-RPC plumbing.

---

## Step 2 — Write the server

Create `server.mcp.py`:

```python
#!/path/to/your/.venv/bin/python3
import os
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("MyServer")

@mcp.tool()
def write_file(path: str, content: str) -> str:
    """Writes content to a specific file path."""
    try:
        os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
        with open(path, "w") as f:
            f.write(content)
        return f"Successfully wrote to {path}"
    except Exception as e:
        return f"Error: {str(e)}"

if __name__ == "__main__":
    mcp.run()
```

Key points:
- The shebang must be an **absolute path** to the virtualenv Python.
- The docstring on the function becomes the tool description Claude sees.
- Type annotations on parameters are required — they define the tool's input schema.
- Return a string. Claude receives it as the tool result.
- `mcp.run()` starts the stdio transport loop.

---

## Step 3 — Make it executable

```bash
chmod +x server.mcp.py
```

---

## Step 4 — Create `.mcp.json`

At the **project root**, create `.mcp.json`:

```json
{
  "mcpServers": {
    "write_file_local": {
      "command": "/absolute/path/to/server.mcp.py",
      "args": []
    }
  }
}
```

Use the absolute path to the script. The server name (`write_file_local`) is arbitrary — Claude Code will prefix tool names with it (e.g. `mcp__write_file_local__write_file`).

---

## Step 5 — Test the server standalone

```bash
echo '{}' | .venv/bin/python3 server.mcp.py
```

You should see a JSON-RPC parse error (expected — the input isn't valid JSON-RPC). What matters is that it doesn't crash on import. A clean startup looks like:

```
Received exception from stream: 1 validation error for JSONRPCMessage ...
```

That means the server started and is waiting for proper JSON-RPC messages.

---

## Step 6 — Connect to Claude Code

1. Start a **new Claude Code chat session** — MCP servers are registered at session startup.
2. Claude Code detects `.mcp.json` and may show a **one-time trust/approval prompt**. Approve it.
3. The tool is now available. Claude can call it directly when asked.

---

## Adding more tools

Just add more decorated functions to the same server:

```python
@mcp.tool()
def read_file(path: str) -> str:
    """Reads and returns the content of a file."""
    with open(path) as f:
        return f.read()

@mcp.tool()
def list_dir(path: str) -> str:
    """Lists files in a directory."""
    return "\n".join(os.listdir(path))
```

Each function becomes a separate tool. Restart Claude Code after changes.

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Tool not available after restart | Wrong config file | Check `.mcp.json` at project root, not `.vscode/mcp.json` |
| Server crashes on startup | Wrong Python path in shebang | Use absolute path: `#!/path/to/.venv/bin/python3` |
| `mcp` not found | Package not installed | Run `.venv/bin/pip install mcp` |
| Tool available but errors | Bug in tool function | Test the function in plain Python first |
