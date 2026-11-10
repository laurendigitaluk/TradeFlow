from __future__ import annotations
import json
import requests

class MCPError(Exception):
    pass

class TradeFlowMCP:
    def __init__(self, endpoint: str, bearer_token: str):
        self.endpoint = endpoint.strip()
        self.token = bearer_token.strip()
        self.session_id = None
        self.protocol_version = "2025-03-26"
        self._next_id = 1

    def _headers(self):
        headers = {
            "Authorization": f"Bearer {self.token}",
            "Content-Type": "application/json",
            "Accept": "application/json, text/event-stream",
            "MCP-Protocol-Version": self.protocol_version,
        }
        if self.session_id:
            headers["MCP-Session-Id"] = self.session_id
        return headers

    @staticmethod
    def _decode_response(response):
        if not response.ok:
            raise MCPError(f"MCP HTTP {response.status_code}: {response.text[:400]}")
        content_type = response.headers.get("content-type", "")
        if "text/event-stream" in content_type:
            for line in response.text.splitlines():
                if line.startswith("data:"):
                    try:
                        return json.loads(line[5:].strip())
                    except json.JSONDecodeError:
                        continue
            raise MCPError("MCP returned an empty or unreadable event stream.")
        if not response.text.strip():
            return {}
        return response.json()

    def _post(self, payload):
        response = requests.post(self.endpoint, headers=self._headers(),
                                 json=payload, timeout=(10, 45))
        self.session_id = response.headers.get("MCP-Session-Id", self.session_id)
        return self._decode_response(response)

    def connect_and_list_tools(self):
        if not self.endpoint or not self.token:
            raise MCPError("Enter the TradeFlow Research MCP endpoint and bearer token.")
        init_id = self._next_id
        self._next_id += 1
        init = self._post({
            "jsonrpc": "2.0", "id": init_id, "method": "initialize",
            "params": {
                "protocolVersion": self.protocol_version,
                "capabilities": {},
                "clientInfo": {"name": "TradeFlow AI Manager", "version": "0.1.0"},
            },
        })
        if init.get("error"):
            raise MCPError(init["error"].get("message", "MCP initialization failed"))
        negotiated = init.get("result", {}).get("protocolVersion")
        if negotiated:
            self.protocol_version = negotiated
        self._post({"jsonrpc": "2.0", "method": "notifications/initialized"})
        req_id = self._next_id
        self._next_id += 1
        result = self._post({"jsonrpc": "2.0", "id": req_id, "method": "tools/list", "params": {}})
        if result.get("error"):
            raise MCPError(result["error"].get("message", "Could not list MCP tools"))
        tools = result.get("result", {}).get("tools", [])
        return [t.get("name", "") for t in tools if t.get("name")]

    def call_tool(self, name: str, arguments: dict):
        req_id = self._next_id
        self._next_id += 1
        result = self._post({
            "jsonrpc": "2.0", "id": req_id, "method": "tools/call",
            "params": {"name": name, "arguments": arguments},
        })
        if result.get("error"):
            raise MCPError(result["error"].get("message", f"{name} failed"))
        return result.get("result", {})
