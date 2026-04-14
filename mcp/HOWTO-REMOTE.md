# How to Run an MCP Tool over HTTP (Remote/TCP)

This guide extends [HOWTO.md](HOWTO.md) to run the same MCP server over HTTP instead of stdio, so it can be accessed from a remote machine or as a persistent background service.

---

## Transport options

FastMCP (mcp 1.27+) supports three transports:

| Transport | Use case |
|---|---|
| `stdio` | Local only. Claude Code launches the process directly. |
| `streamable-http` | **Standard remote transport** (MCP spec 2025-03-26). HTTP POST + SSE on a single endpoint. |
| `sse` | Legacy remote transport. Separate SSE stream endpoint. Widely supported but being superseded. |

Use `streamable-http` for new deployments.

---

## Step 1 — Modify the server

Change the `mcp.run()` call. Everything else stays the same.

```python
#!/path/to/.venv/bin/python3
import os
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("SimpleFileServer")

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
    mcp.run(transport="streamable-http")
```

**Defaults:**
- Host: `127.0.0.1` (localhost only)
- Port: `8000`
- Endpoint: `http://127.0.0.1:8000/mcp`

To listen on all interfaces (needed for remote access):

```python
mcp = FastMCP("SimpleFileServer", host="0.0.0.0", port=8000)
```

---

## Step 2 — Install uvicorn (if not already present)

HTTP transports require uvicorn, which is included with the `mcp` package:

```bash
.venv/bin/pip install "mcp[cli]"
```

Or just verify it's there:

```bash
.venv/bin/python3 -c "import uvicorn; print(uvicorn.__version__)"
```

---

## Step 3 — Run the server

```bash
.venv/bin/python3 server.mcp.py
```

You should see:

```
INFO:     Started server process [...]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
```

Test it is up:

```bash
curl -s http://127.0.0.1:8000/mcp
```

---

## Step 4 — Configure `.mcp.json`

For a remote server, use the `url` key instead of `command`:

```json
{
  "mcpServers": {
    "write_file_remote": {
      "url": "http://127.0.0.1:8000/mcp"
    }
  }
}
```

For a server on another machine, replace `127.0.0.1` with the remote hostname or IP, and ensure port `8000` is reachable.

---

## Step 5 — Connect Claude Code

Start a new Claude Code chat session. It will connect to the running HTTP server at startup. No process launching — Claude Code is now a client, not a process manager.

**Important difference from stdio:**
- With `stdio`: Claude Code *launches* the server process.
- With HTTP: The server must already be *running*. Claude Code just connects.

---

## Running as a persistent service (systemd)

Create `/etc/systemd/system/mcp-write-file.service`:

```ini
[Unit]
Description=MCP write_file server
After=network.target

[Service]
User=rap
WorkingDirectory=/home/rap/ong/fastmcp
ExecStart=/home/rap/ong/fastmcp/.venv/bin/python3 /home/rap/ong/fastmcp/server.mcp.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl enable mcp-write-file
sudo systemctl start mcp-write-file
sudo systemctl status mcp-write-file
```

---

## Legacy SSE transport

If you need compatibility with older MCP clients, use `sse` instead:

```python
mcp.run(transport="sse")
```

The endpoint changes to `/sse`:

```json
{
  "mcpServers": {
    "write_file_remote": {
      "url": "http://127.0.0.1:8000/sse"
    }
  }
}
```

---

## Stdio vs HTTP comparison

| | stdio | streamable-http |
|---|---|---|
| Server lifecycle | Managed by Claude Code | You manage it |
| Network | None (local pipes) | HTTP (local or remote) |
| Multiple clients | No | Yes |
| Remote access | No | Yes |
| `.mcp.json` key | `command` | `url` |
| Default endpoint | — | `/mcp` |
