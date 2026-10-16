-- Candidate-only regression checks. Run after fixture.sql and the four
-- candidate migrations in an isolated PostgreSQL database. Never run on LIVE.
select set_config('request.jwt.claim.role', 'service_role', false);

insert into public.payment_records
  (id, tenant_id, retail_order_id, amount, currency, status)
values
  ('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
   'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
   '11111111-1111-4111-8111-111111111111', 125.00, 'GBP', 'pending'),
  ('dddddddd-dddd-4ddd-8ddd-dddddddddddd',
   'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
   '22222222-2222-4222-8222-222222222222', 70.00, 'GBP', 'pending'),
  ('ffffffff-ffff-4fff-8fff-ffffffffffff',
   'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
   '33333333-3333-4333-8333-333333333333', 55.00, 'GBP', 'failed');

insert into public.retail_checkout_attempts
  (id, tenant_id, payment_id, attempt_number, idempotency_key, status,
   stripe_session_id, stripe_payment_intent_id, stripe_account_id)
values
  ('cccccccc-cccc-4ccc-8ccc-cccccccccccc',
   'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
   'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 1, 'test-checkout-success', 'open',
   'cs_test_success', 'pi_test_success', 'acct_test_expected'),
  ('eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
   'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
   'dddddddd-dddd-4ddd-8ddd-dddddddddddd', 1, 'test-checkout-fallback', 'open',
   'cs_test_fallback', 'pi_test_fallback', 'acct_test_expected'),
  ('99999999-9999-4999-8999-999999999999',
   'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
   'ffffffff-ffff-4fff-8fff-ffffffffffff', 1, 'test-checkout-refund', 'failed',
   'cs_test_refund', 'pi_test_refund', 'acct_test_expected');

do $test$
declare
  v jsonb;
  v_status text;
  v_metadata jsonb;
begin
  -- Connected-account mismatch must stop before recording or settling.
  v := public.process_retail_checkout_attempt_event(
    'evt_test_wrong_account', 'checkout.session.completed',
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'acct_wrong',
    'cs_test_success', 'pi_test_success', 'paid', 125.00, 'GBP', '{}'::jsonb);
  if v->>'outcome' is distinct from 'reconciliation_required'
     or v->>'reason' is distinct from 'connected_account_mismatch' then
    raise exception 'Expected connected-account mismatch, got %', v;
  end if;

  -- PaymentIntent mismatch must stop before recording or settling.
  v := public.process_retail_checkout_attempt_event(
    'evt_test_wrong_payment_intent', 'checkout.session.completed',
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'acct_test_expected',
    'cs_test_success', 'pi_test_wrong', 'paid', 125.00, 'GBP', '{}'::jsonb);
  if v->>'outcome' is distinct from 'reconciliation_required'
     or v->>'reason' is distinct from 'payment_intent_mismatch' then
    raise exception 'Expected PaymentIntent mismatch, got %', v;
  end if;
  if exists (select 1 from public.payment_provider_events where event_id = 'evt_test_wrong_payment_intent') then
    raise exception 'PaymentIntent mismatch unexpectedly recorded a provider event';
  end if;

  -- Amount mismatch must not change the payment or write a provider event.
  v := public.process_retail_checkout_attempt_event(
    'evt_test_wrong_amount', 'checkout.session.completed',
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'acct_test_expected',
    'cs_test_success', 'pi_test_success', 'paid', 124.99, 'GBP', '{}'::jsonb);
  if v->>'outcome' is distinct from 'reconciliation_required'
     or v->>'reason' is distinct from 'amount_or_currency_mismatch' then
    raise exception 'Expected amount mismatch, got %', v;
  end if;
  if exists (select 1 from public.payment_provider_events where event_id = 'evt_test_wrong_amount') then
    raise exception 'Amount mismatch unexpectedly recorded a provider event';
  end if;

  -- Successful settlement updates the payment and completes the exact attempt.
  v := public.process_retail_checkout_attempt_event(
    'evt_test_success', 'checkout.session.completed',
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'acct_test_expected',
    'cs_test_success', 'pi_test_success', 'paid', 125.00, 'GBP', '{}'::jsonb);
  if v->>'outcome' is distinct from 'applied' then
    raise exception 'Expected applied settlement, got %', v;
  end if;
  if (select status from public.payment_records where id = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb') is distinct from 'paid'
     or (select status from public.retail_checkout_attempts where id = 'cccccccc-cccc-4ccc-8ccc-cccccccccccc') is distinct from 'completed' then
    raise exception 'Successful settlement did not update both payment and attempt';
  end if;

  -- A paid late Session for the same payment must create a refund intent,
  -- not settle the same retail order a second time.
  insert into public.retail_checkout_attempts
    (id, tenant_id, payment_id, attempt_number, idempotency_key, status,
     stripe_session_id, stripe_payment_intent_id, stripe_account_id)
  values
    ('abababab-abab-4bab-8bab-abababababab',
     'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
     'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 2, 'test-checkout-late-session', 'open',
     'cs_test_late', 'pi_test_late', 'acct_test_expected');
  v := public.process_retail_checkout_attempt_event(
    'evt_test_late_paid_session', 'checkout.session.completed',
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'acct_test_expected',
    'cs_test_late', 'pi_test_late', 'paid', 125.00, 'GBP', '{}'::jsonb);
  if v->>'outcome' is distinct from 'refund_required' or v->>'refund_status' is distinct from 'required' then
    raise exception 'Expected late paid Session refund intent, got %', v;
  end if;
  if (select refund_status from public.retail_checkout_attempts where id = 'abababab-abab-4bab-8bab-abababababab') is distinct from 'required' then
    raise exception 'Late paid Session did not persist a refund intent';
  end if;
  if (select status from public.payment_records where id = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb') is distinct from 'paid' then
    raise exception 'Late paid Session changed the already-settled payment';
  end if;

  -- Sequential duplicate delivery must not settle again.
  v := public.process_retail_checkout_attempt_event(
    'evt_test_success', 'checkout.session.completed',
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'acct_test_expected',
    'cs_test_success', 'pi_test_success', 'paid', 125.00, 'GBP', '{}'::jsonb);
  if v->>'outcome' is distinct from 'duplicate' then
    raise exception 'Expected duplicate event outcome, got %', v;
  end if;

  -- Model the downstream business transition declining a payment after it
  -- has already recorded the Stripe event. The candidate must persist refund
  -- intent without a duplicate-key exception or transaction rollback.
  v := public.process_retail_checkout_attempt_event(
    'evt_test_refund_fallback', 'checkout.session.completed',
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'acct_test_expected',
    'cs_test_fallback', 'pi_test_fallback', 'paid', 70.00, 'GBP',
    '{"force_reject":"true"}'::jsonb);
  if v->>'outcome' is distinct from 'refund_required' then
    raise exception 'Expected refund_required fallback, got %', v;
  end if;
  if (select refund_status from public.retail_checkout_attempts where id = 'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee') is distinct from 'required' then
    raise exception 'Refund intent was not persisted';
  end if;
  select metadata into v_metadata from public.payment_provider_events where event_id = 'evt_test_refund_fallback';
  if v_metadata->>'settlement_outcome' is distinct from 'refund_required' then
    raise exception 'Existing provider event was not updated with refund outcome: %', v_metadata;
  end if;

  -- Refund claim is recoverable and completion is idempotently recorded.
  update public.retail_checkout_attempts
     set refund_status = 'required',
         refund_idempotency_key = 'tradeflow-refund-test-claim'
   where id = '99999999-9999-4999-8999-999999999999';
  select claim_status into v_status
    from public.claim_retail_checkout_refund('99999999-9999-4999-8999-999999999999');
  if v_status is distinct from 'claimed' then
    raise exception 'Expected refund claim, got %', v_status;
  end if;
  v := public.finish_retail_checkout_refund(
    '99999999-9999-4999-8999-999999999999',
    'tradeflow-refund-test-claim', 'succeeded',
    're_test_refund', 'pi_test_refund', null);
  if v->>'outcome' is distinct from 'succeeded' then
    raise exception 'Expected refund success transition, got %', v;
  end if;
  v := public.finish_retail_checkout_refund(
    '99999999-9999-4999-8999-999999999999',
    'tradeflow-refund-test-claim', 'succeeded',
    're_test_refund', 'pi_test_refund', null);
  if v->>'outcome' is distinct from 'already_succeeded' then
    raise exception 'Expected idempotent already_succeeded, got %', v;
  end if;
end
$test$;

select 'Stripe Connect SQL regression checks passed' as result;
