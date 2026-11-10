from __future__ import annotations
import threading
import tkinter as tk
from tkinter import ttk, messagebox
import keyring

from tradeflow_manager.store import Store
from tradeflow_manager.providers import ProviderRouter, ProviderError
from tradeflow_manager.mcp_client import TradeFlowMCP, MCPError

SERVICE = "TradeFlowAIManager"
PROVIDERS = ("groq", "gemini", "openrouter")
DEFAULT_MCP = "https://gxsrajtqzdjvmceqcpgv.supabase.co/functions/v1/tradeflow-research-mcp"
REQUIRED_RESEARCH_TOOLS = {"list_catalogue_products", "list_research_sources",
                           "get_existing_evidence", "submit_research_report"}

class ManagerApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("TradeFlow AI Manager")
        self.geometry("900x720")
        self.minsize(780, 620)
        self.store = Store()
        self.vars = {}
        self._build()
        self._refresh_summary()
        self._load_saved_settings()

    def _build(self):
        root = ttk.Frame(self, padding=18)
        root.pack(fill="both", expand=True)
        ttk.Label(root, text="TradeFlow AI Manager", font=("Segoe UI", 20, "bold")).pack(anchor="w")
        ttk.Label(root, text="Free-only cloud research control • local progress • no paid fallback",
                  foreground="#555").pack(anchor="w", pady=(2, 14))

        summary = ttk.LabelFrame(root, text="Research queue", padding=12)
        summary.pack(fill="x", pady=(0, 12))
        self.summary_label = ttk.Label(summary, text="Loading queue…")
        self.summary_label.pack(anchor="w")
        self.readiness_label = ttk.Label(summary, text="Research readiness: checking configuration…")
        self.readiness_label.pack(anchor="w", pady=(6, 0))

        providers = ttk.LabelFrame(root, text="Cloud providers — free plans only", padding=12)
        providers.pack(fill="x", pady=(0, 12))
        self.provider_widgets = {}
        for idx, provider in enumerate(PROVIDERS):
            frame = ttk.Frame(providers)
            frame.grid(row=idx, column=0, sticky="ew", pady=4)
            providers.columnconfigure(0, weight=1)
            ttk.Label(frame, text=provider.title(), width=14).pack(side="left")
            key_var = tk.StringVar()
            model_var = tk.StringVar(value=self.store.get_state(f"{provider}.model"))
            self.vars[f"{provider}.key"] = key_var
            self.vars[f"{provider}.model"] = model_var
            key_entry = ttk.Entry(frame, textvariable=key_var, show="•", width=30)
            key_entry.pack(side="left", padx=(0, 8))
            key_entry.insert(0, "")
            ttk.Label(frame, text="Model").pack(side="left")
            model_entry = ttk.Entry(frame, textvariable=model_var, width=34)
            model_entry.pack(side="left", padx=(6, 8), fill="x", expand=True)
            ttk.Button(frame, text="Test", command=lambda p=provider: self._run_async(self._test_provider, p)).pack(side="left")
            self.provider_widgets[provider] = (key_entry, model_entry)

        mcp = ttk.LabelFrame(root, text="TradeFlow Research MCP", padding=12)
        mcp.pack(fill="x", pady=(0, 12))
        self.vars["mcp.endpoint"] = tk.StringVar(value=DEFAULT_MCP)
        self.vars["mcp.token"] = tk.StringVar()
        ttk.Label(mcp, text="Endpoint").grid(row=0, column=0, sticky="w")
        ttk.Entry(mcp, textvariable=self.vars["mcp.endpoint"], width=95).grid(row=0, column=1, sticky="ew", padx=8, pady=3)
        ttk.Label(mcp, text="Bearer token").grid(row=1, column=0, sticky="w")
        ttk.Entry(mcp, textvariable=self.vars["mcp.token"], show="•", width=95).grid(row=1, column=1, sticky="ew", padx=8, pady=3)
        mcp.columnconfigure(1, weight=1)
        ttk.Button(mcp, text="Test MCP connection", command=lambda: self._run_async(self._test_mcp)).grid(row=2, column=1, sticky="e", pady=(6, 0))

        actions = ttk.Frame(root)
        actions.pack(fill="x", pady=(2, 10))
        ttk.Button(actions, text="Save settings securely", command=self._save).pack(side="left")
        ttk.Button(actions, text="Check all providers", command=lambda: self._run_async(self._test_all)).pack(side="left", padx=8)
        ttk.Button(actions, text="Refresh dashboard", command=self._refresh_summary).pack(side="left")
        self.status = tk.StringVar(value="Not connected. Add free-plan API keys and test the MCP connection.")
        ttk.Label(root, textvariable=self.status, wraplength=840, foreground="#333").pack(anchor="w", pady=(8, 0))

        note = ttk.LabelFrame(root, text="Safety and current limitations", padding=12)
        note.pack(fill="both", expand=True, pady=(12, 0))
        notes = (
            "• Provider keys are stored in Windows Credential Manager, not in the project or local database.\n"
            "• OpenRouter models are accepted only when their model ID ends in :free.\n"
            "• Groq and Gemini must use accounts with billing disabled; this app never enables billing or buys credits.\n"
            "• If a provider returns a quota/rate-limit error, it is skipped. If all free providers are unavailable, work pauses.\n"
            "• The existing MCP is report-only. It currently lacks paginated catalogue listing and research-source listing.\n"
            "• Catalogue-wide scanning remains disabled until those missing tools and a compliant web-search layer are tested on TEST.\n"
            "• Research reports go to the private inbox for review; this app does not write directly to shared market evidence."
        )
        ttk.Label(note, text=notes, justify="left", wraplength=830).pack(anchor="w")

    def _load_saved_settings(self):
        for p in PROVIDERS:
            try:
                key = keyring.get_password(SERVICE, f"{p}.api_key")
                if key:
                    self.status.set(f"{p.title()} key is already stored securely. Enter a replacement only if needed.")
            except Exception:
                self.status.set("Windows Credential Manager is unavailable. Credentials cannot be stored safely.")
        try:
            token = keyring.get_password(SERVICE, "tradeflow_mcp_token")
            if token:
                self.status.set("Saved MCP credential found in Windows Credential Manager. Re-enter it to test the connection.")
        except Exception:
            pass

    def _save(self):
        try:
            for p in PROVIDERS:
                key = self.vars[f"{p}.key"].get().strip()
                if key:
                    keyring.set_password(SERVICE, f"{p}.api_key", key)
                    self.vars[f"{p}.key"].set("")
                self.store.set_state(f"{p}.model", self.vars[f"{p}.model"].get().strip())
            endpoint = self.vars["mcp.endpoint"].get().strip()
            self.store.set_state("mcp.endpoint", endpoint)
            token = self.vars["mcp.token"].get().strip()
            if token:
                keyring.set_password(SERVICE, "tradeflow_mcp_token", token)
                self.vars["mcp.token"].set("")
            self.status.set("Settings saved. API keys and MCP token are stored in Windows Credential Manager.")
        except Exception as exc:
            messagebox.showerror("Could not save securely", str(exc))

    def _credentials(self):
        data = {}
        for p in PROVIDERS:
            key = self.vars[f"{p}.key"].get().strip()
            if not key:
                try:
                    key = keyring.get_password(SERVICE, f"{p}.api_key") or ""
                except Exception:
                    key = ""
            data[p] = {"key": key, "model": self.vars[f"{p}.model"].get().strip()}
        return data

    def _mcp(self):
        token = self.vars["mcp.token"].get().strip()
        if not token:
            token = keyring.get_password(SERVICE, "tradeflow_mcp_token") or ""
        return TradeFlowMCP(self.vars["mcp.endpoint"].get().strip(), token)

    def _run_async(self, fn, *args):
        self.status.set("Working…")
        def runner():
            try:
                result = fn(*args)
                self.after(0, lambda: self.status.set(str(result)))
            except Exception as exc:
                self.after(0, lambda: self.status.set(f"Check failed: {exc}"))
        threading.Thread(target=runner, daemon=True).start()

    def _test_provider(self, provider):
        router = ProviderRouter(self._credentials())
        models = router.list_models(provider)
        if provider == "openrouter" and not models:
            return "OpenRouter connected, but no :free models are currently listed."
        return f"{provider.title()} connected. {len(models)} model(s) listed. OpenRouter list is filtered to :free models."

    def _test_all(self):
        results = []
        router = ProviderRouter(self._credentials())
        for p in PROVIDERS:
            try:
                models = router.list_models(p)
                results.append(f"{p}: {len(models)} models")
            except ProviderError as exc:
                results.append(f"{p}: unavailable ({exc})")
        return "Provider check: " + " | ".join(results)

    def _test_mcp(self):
        tools = self._mcp().connect_and_list_tools()
        missing = sorted(REQUIRED_RESEARCH_TOOLS - set(tools))
        if missing:
            self.readiness_label.configure(text="Research readiness: MCP connected; full-catalogue mode is locked until missing tools are added.")
            return f"MCP connected. Tools: {', '.join(tools)}. Missing for full research: {', '.join(missing)}."
        self.readiness_label.configure(text="Research readiness: MCP tools available; search layer still requires validation.")
        return f"MCP connected. Available tools: {', '.join(tools)}."

    def _refresh_summary(self):
        counts = self.store.summary()
        self.summary_label.configure(text="Queued: {queued}   Running: {running}   Submitted: {submitted}   Paused: {paused}   Failed: {failed}".format(**counts))
        self.readiness_label.configure(text="Research readiness: awaiting provider and MCP connection checks.")

if __name__ == "__main__":
    ManagerApp().mainloop()
