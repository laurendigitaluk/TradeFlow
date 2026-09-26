-- External payment completion now checks that the linked listing is still published.
-- If another customer has already bought it, the function returns false without
-- marking the payment/order paid; the Stripe webhook refunds the conflicting payment
-- and records the retail order as cancelled.
-- This prevents an abandoned pending checkout from blocking the live shop.
/* live function definition is recorded in Supabase migration 20260926173000_retail_payment_claim_after_payment */