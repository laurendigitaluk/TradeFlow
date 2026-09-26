-- Retail checkout must not reserve or delist a product before payment.
-- The listing remains published while the customer is deciding/payment is pending.
-- Successful payment is the only point at which the listing is moved to sold.
/* live function definitions are recorded in Supabase migration 20260926170000_retail_checkout_no_reservation_before_payment */