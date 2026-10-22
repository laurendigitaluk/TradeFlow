-- Keep shared market evidence platform-managed. Subscribers may read active rows only.
REVOKE ALL PRIVILEGES ON TABLE public.shared_market_evidence FROM anon, authenticated;
GRANT SELECT ON TABLE public.shared_market_evidence TO authenticated;
GRANT ALL PRIVILEGES ON TABLE public.shared_market_evidence TO service_role;
