"""Concurrent duplicate-event regression for the isolated candidate PostgreSQL DB."""
import os
import threading
from concurrent.futures import ThreadPoolExecutor

import psycopg

TENANT = "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa"
PAYMENTS = [
    ("12111111-1111-4111-8111-111111111111", "12111111-1111-4111-8111-111111111112"),
    ("13111111-1111-4111-8111-111111111111", "13111111-1111-4111-8111-111111111112"),
]
EVENT_ID = "evt_test_concurrent_duplicate"
ACCOUNT = "acct_test_concurrent"
SESSIONS = ["cs_test_concurrent_a", "cs_test_concurrent_b"]


def connect():
    return psycopg.connect(
        host=os.getenv("PGHOST", "localhost"),
        port=os.getenv("PGPORT", "5432"),
        dbname=os.getenv("PGDATABASE", "tradeflow_test"),
        user=os.getenv("PGUSER", "postgres"),
        password=os.getenv("PGPASSWORD", "postgres"),
    )


def prepare():
    with connect() as conn:
        for i, (payment_id, attempt_id) in enumerate(PAYMENTS):
            conn.execute(
                """
                insert into public.payment_records
                  (id, tenant_id, retail_order_id, amount, currency, status)
                values (%s, %s, %s, 10.00, 'GBP', 'pending')
                """,
                (payment_id, TENANT, f"14111111-1111-4111-8111-{i + 1:012d}"),
            )
            conn.execute(
                """
                insert into public.retail_checkout_attempts
                  (id, tenant_id, payment_id, attempt_number, idempotency_key,
                   status, stripe_session_id, stripe_payment_intent_id, stripe_account_id)
                values (%s, %s, %s, 1, %s, 'open', %s, %s, %s)
                """,
                (
                    attempt_id,
                    TENANT,
                    payment_id,
                    f"test-concurrent-attempt-{i}",
                    SESSIONS[i],
                    f"pi_test_concurrent_{i}",
                    ACCOUNT,
                ),
            )


def deliver(index, barrier):
    payment_id, attempt_id = PAYMENTS[index]
    with connect() as conn:
        conn.execute("select set_config('request.jwt.claim.role', 'service_role', true)")
        barrier.wait(timeout=10)
        row = conn.execute(
            """
            select public.process_retail_checkout_attempt_event(
              %s, 'checkout.session.completed', %s, %s, %s, %s,
              'paid', 10.00, 'GBP', '{}'::jsonb
            )
            """,
            (
                EVENT_ID,
                TENANT,
                ACCOUNT,
                SESSIONS[index],
                f"pi_test_concurrent_{index}",
            ),
        ).fetchone()
        return row[0]


def main():
    prepare()
    barrier = threading.Barrier(2)
    with ThreadPoolExecutor(max_workers=2) as pool:
        outcomes = list(pool.map(lambda i: deliver(i, barrier), range(2)))

    labels = sorted(result.get("outcome", "missing") for result in outcomes)
    if labels != ["applied", "duplicate"]:
        raise SystemExit(f"Expected one applied and one duplicate result; got {outcomes}")

    with connect() as conn:
        count = conn.execute(
            "select count(*) from public.payment_provider_events where provider='stripe' and event_id=%s",
            (EVENT_ID,),
        ).fetchone()[0]
        if count != 1:
            raise SystemExit(f"Expected one provider event row, got {count}")

    print("Concurrent duplicate Stripe event regression passed: one applied, one duplicate.")


if __name__ == "__main__":
    main()
