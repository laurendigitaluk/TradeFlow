from __future__ import annotations
import sqlite3
from pathlib import Path
from typing import Any

APP_DIR = Path.home() / "AppData" / "Local" / "TradeFlowAIManager"
DB_PATH = APP_DIR / "manager.sqlite3"

class Store:
    def __init__(self, path: Path | str = DB_PATH):
        self.path = Path(path)
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self._init()

    def _connect(self):
        db = sqlite3.connect(self.path, timeout=15)
        db.row_factory = sqlite3.Row
        return db

    def _init(self):
        with self._connect() as db:
            db.executescript("""
            PRAGMA journal_mode=WAL;
            CREATE TABLE IF NOT EXISTS jobs (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              product_id TEXT NOT NULL,
              product_label TEXT NOT NULL DEFAULT '',
              category_slug TEXT,
              status TEXT NOT NULL DEFAULT 'queued'
                CHECK(status IN ('queued','running','submitted','paused','failed')),
              provider TEXT,
              attempts INTEGER NOT NULL DEFAULT 0,
              last_error TEXT,
              report_id TEXT,
              created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
              updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
              UNIQUE(product_id, status) ON CONFLICT IGNORE
            );
            CREATE TABLE IF NOT EXISTS provider_state (
              provider TEXT PRIMARY KEY,
              enabled INTEGER NOT NULL DEFAULT 0,
              model TEXT NOT NULL DEFAULT '',
              last_status TEXT NOT NULL DEFAULT 'not_checked',
              unavailable_until TEXT,
              last_error TEXT,
              updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
            );
            CREATE TABLE IF NOT EXISTS app_state (
              key TEXT PRIMARY KEY,
              value TEXT NOT NULL
            );
            CREATE INDEX IF NOT EXISTS idx_jobs_status_id ON jobs(status,id);
            """)

    def summary(self) -> dict[str, int]:
        with self._connect() as db:
            rows = db.execute("SELECT status, COUNT(*) n FROM jobs GROUP BY status").fetchall()
        result = {k: 0 for k in ("queued","running","submitted","paused","failed")}
        result.update({r["status"]: r["n"] for r in rows})
        return result

    def enqueue(self, product_id: str, label: str = "", category_slug: str | None = None):
        with self._connect() as db:
            db.execute(
                """INSERT OR IGNORE INTO jobs(product_id,product_label,category_slug)
                   VALUES(?,?,?)""", (product_id, label, category_slug)
            )

    def next_job(self):
        with self._connect() as db:
            row = db.execute(
                "SELECT * FROM jobs WHERE status='queued' ORDER BY id LIMIT 1"
            ).fetchone()
            return dict(row) if row else None

    def mark(self, job_id: int, status: str, **fields: Any):
        allowed = {"provider","attempts","last_error","report_id"}
        values = {k:v for k,v in fields.items() if k in allowed}
        values["status"] = status
        values["updated_at"] = "CURRENT_TIMESTAMP"
        assignments = [f"{k}=?" for k in values if k != "updated_at"]
        params = [values[k] for k in values if k != "updated_at"]
        assignments.append("updated_at=CURRENT_TIMESTAMP")
        with self._connect() as db:
            db.execute(f"UPDATE jobs SET {','.join(assignments)} WHERE id=?", (*params, job_id))

    def set_state(self, key: str, value: str):
        with self._connect() as db:
            db.execute(
                "INSERT INTO app_state(key,value) VALUES(?,?) "
                "ON CONFLICT(key) DO UPDATE SET value=excluded.value",
                (key, value),
            )

    def get_state(self, key: str, default: str = "") -> str:
        with self._connect() as db:
            row = db.execute("SELECT value FROM app_state WHERE key=?", (key,)).fetchone()
        return row["value"] if row else default
