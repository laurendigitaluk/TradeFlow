from __future__ import annotations
from dataclasses import dataclass
import requests

TIMEOUT = (10, 90)

@dataclass
class ProviderResult:
    provider: str
    model: str
    text: str

class ProviderError(Exception):
    def __init__(self, provider: str, message: str, retryable: bool = False):
        super().__init__(message)
        self.provider = provider
        self.retryable = retryable

class ProviderRouter:
    """OpenAI-compatible cloud inference with explicit free-only routing.

    API keys are supplied by the caller from Windows Credential Manager.
    This class never purchases credits, changes billing, or selects a paid model.
    """
    ENDPOINTS = {
        "groq": "https://api.groq.com/openai/v1/chat/completions",
        "gemini": "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions",
        "openrouter": "https://openrouter.ai/api/v1/chat/completions",
    }

    def __init__(self, credentials: dict[str, dict[str, str]]):
        self.credentials = credentials

    @staticmethod
    def is_free_model(provider: str, model: str) -> bool:
        if provider == "openrouter":
            return model.strip().endswith(":free")
        # Groq and Gemini keys must be created on their no-billing/free plans.
        return provider in ("groq", "gemini") and bool(model.strip())

    def _headers(self, provider: str, key: str):
        headers = {"Authorization": f"Bearer {key}", "Content-Type": "application/json"}
        if provider == "gemini":
            headers.pop("Authorization", None)
            headers["x-goog-api-key"] = key
        if provider == "openrouter":
            headers["HTTP-Referer"] = "https://tradeflow.laurendigital.co.uk"
            headers["X-Title"] = "TradeFlow AI Manager"
        return headers

    def list_models(self, provider: str) -> list[str]:
        cfg = self.credentials.get(provider, {})
        key = cfg.get("key", "").strip()
        if not key:
            raise ProviderError(provider, "API key has not been saved.")
        if provider == "groq":
            url = "https://api.groq.com/openai/v1/models"
            headers = {"Authorization": f"Bearer {key}"}
            response = requests.get(url, headers=headers, timeout=TIMEOUT)
            self._raise(provider, response)
            return sorted(x["id"] for x in response.json().get("data", []))
        if provider == "openrouter":
            response = requests.get("https://openrouter.ai/api/v1/models",
                                    headers=self._headers(provider, key), timeout=TIMEOUT)
            self._raise(provider, response)
            return sorted(x["id"] for x in response.json().get("data", [])
                          if x.get("id", "").endswith(":free"))
        if provider == "gemini":
            response = requests.get("https://generativelanguage.googleapis.com/v1beta/models",
                                    headers={"x-goog-api-key": key}, timeout=TIMEOUT)
            self._raise(provider, response)
            return sorted(x["name"].removeprefix("models/") for x in response.json().get("models", [])
                          if "generateContent" in x.get("supportedGenerationMethods", []))
        raise ProviderError(provider, "Unknown provider.")

    @staticmethod
    def _raise(provider: str, response: requests.Response):
        if response.ok:
            return
        retryable = response.status_code in (402, 408, 429, 500, 502, 503, 504)
        detail = response.text[:500]
        raise ProviderError(provider, f"HTTP {response.status_code}: {detail}", retryable)

    def complete(self, messages: list[dict], order: list[str]) -> ProviderResult:
        failures = []
        for provider in order:
            cfg = self.credentials.get(provider, {})
            key, model = cfg.get("key", "").strip(), cfg.get("model", "").strip()
            if not key or not model or not self.is_free_model(provider, model):
                continue
            response = None
            try:
                response = requests.post(
                    self.ENDPOINTS[provider],
                    headers=self._headers(provider, key),
                    json={"model": model, "messages": messages, "temperature": 0.1},
                    timeout=TIMEOUT,
                )
                self._raise(provider, response)
                data = response.json()
                text = data["choices"][0]["message"]["content"]
                if not isinstance(text, str) or not text.strip():
                    raise ProviderError(provider, "Provider returned an empty response.")
                return ProviderResult(provider, model, text)
            except ProviderError as exc:
                failures.append(f"{provider}: {exc}")
                # Never attempt a paid fallback. Move only to another explicitly
                # configured free provider; 401/403 errors also skip this provider.
                continue
            except (requests.RequestException, KeyError, ValueError, IndexError) as exc:
                failures.append(f"{provider}: {exc}")
                continue
        raise ProviderError("router", "No configured free provider is currently usable. " + " | ".join(failures))
