-- Client writes are blocked by table privileges; retain only the active-row SELECT policy.
-- Remove the actual deny policy name present in TEST without granting write access.
DROP POLICY IF EXISTS shared_market_evidence_deny_client_writes ON public.shared_market_evidence;
