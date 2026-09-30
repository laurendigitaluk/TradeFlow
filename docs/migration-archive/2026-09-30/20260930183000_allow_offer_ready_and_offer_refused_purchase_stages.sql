alter table public.buying_items drop constraint if exists buying_items_purchase_stage_check;

alter table public.buying_items add constraint buying_items_purchase_stage_check
check (
  purchase_stage = any (array[
    'none'::text,
    'offer_ready'::text,
    'offer_refused'::text,
    'awaiting_item'::text,
    'shipping'::text,
    'received'::text,
    'inspection'::text,
    'testing'::text,
    'repair'::text,
    'return_pending'::text,
    'final_offer_required'::text,
    'final_offer_sent'::text,
    'final_offer_accepted'::text,
    'final_offer_refused'::text,
    'payment_pending'::text,
    'purchased'::text
  ]::text[]
));