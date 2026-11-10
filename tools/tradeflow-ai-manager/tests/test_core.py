from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from tradeflow_manager.providers import ProviderRouter
from tradeflow_manager.store import Store

def test_openrouter_only_accepts_free_models():
    assert ProviderRouter.is_free_model("openrouter", "vendor/model:free")
    assert not ProviderRouter.is_free_model("openrouter", "vendor/model")
    assert not ProviderRouter.is_free_model("openrouter", "vendor/model:paid")

def test_free_providers_require_model_name():
    assert ProviderRouter.is_free_model("groq", "some-model")
    assert not ProviderRouter.is_free_model("groq", "")
    assert ProviderRouter.is_free_model("gemini", "gemini-flash")
    assert not ProviderRouter.is_free_model("unknown", "model")

def test_local_queue_persists_and_deduplicates(tmp_path: Path):
    db = tmp_path / "manager.sqlite3"
    store = Store(db)
    store.enqueue("product-1", "Camera One", "cameras")
    store.enqueue("product-1", "Camera One", "cameras")
    assert store.summary()["queued"] == 1
    assert store.next_job()["product_id"] == "product-1"
    reopened = Store(db)
    assert reopened.summary()["queued"] == 1

def test_queue_status_counts(tmp_path: Path):
    store = Store(tmp_path / "manager.sqlite3")
    store.enqueue("p1", "Product 1")
    job = store.next_job()
    store.mark(job["id"], "paused", last_error="quota")
    assert store.summary()["queued"] == 0
    assert store.summary()["paused"] == 1
