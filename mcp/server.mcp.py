#!/home/rap/ong/fastmcp/.venv/bin/python3
import os
from mcp.server.fastmcp import FastMCP

# Initialize the server
mcp = FastMCP("SimpleFileServer")

@mcp.tool()
def write_file(path: str, content: str) -> str:
    """Writes content to a specific file path."""
    try:
        os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
        with open(path, "w") as f: f.write(content)
        return f"Successfully wrote to {path}"
    except Exception as e: return f"Error: {str(e)}"

if __name__ == "__main__": mcp.run()
