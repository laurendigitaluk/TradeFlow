-- TradeFlow LIVE retirement of the local research-worker runtime.
-- Applied to LIVE as migration 20261110173027.
-- Revoke all execution for the worker/control-plane RPC surface.
-- Historical tables and rows are intentionally preserved for audit and review.

revoke all on function public.platform_ai_agent_claim_task(text, integer) from public, anon, authenticated, service_role;
revoke all on function public.platform_ai_agent_claim_task_for_agents(text, text[], integer) from public, anon, authenticated, service_role;
revoke all on function public.platform_ai_agent_complete_task(uuid, text, jsonb) from public, anon, authenticated, service_role;
revoke all on function public.platform_ai_agent_fail_task(uuid, text, text) from public, anon, authenticated, service_role;
revoke all on function public.platform_ai_agent_heartbeat_task(uuid, text, integer) from public, anon, authenticated, service_role;
revoke all on function public.platform_ai_agent_list_messages(text, text, text, text, integer, timestamptz) from public, anon, authenticated, service_role;
revoke all on function public.platform_ai_agent_post_message(text, text, text, text, text, text, text, text, text, text, uuid, jsonb) from public, anon, authenticated, service_role;
revoke all on function public.platform_ai_agent_report_event(text, text, text, text, text, text, text, text, integer, integer, integer, text, jsonb) from public, anon, authenticated, service_role;
revoke all on function public.platform_owner_add_research_source(text, text, text, text, text, text) from public, anon, authenticated, service_role;
revoke all on function public.platform_owner_enqueue_ai_agent_task(text, jsonb, integer) from public, anon, authenticated, service_role;
revoke all on function public.platform_owner_get_ai_agent_control_centre(integer) from public, anon, authenticated, service_role;
revoke all on function public.platform_owner_list_ai_agent_messages(text, text, integer, timestamptz) from public, anon, authenticated, service_role;
revoke all on function public.platform_owner_list_ai_agent_tasks(integer, text) from public, anon, authenticated, service_role;
revoke all on function public.platform_owner_list_gemma_research_categories() from public, anon, authenticated, service_role;
revoke all on function public.platform_owner_list_gemma_research_products(text, text, text, integer) from public, anon, authenticated, service_role;
revoke all on function public.platform_owner_list_research_sources(text) from public, anon, authenticated, service_role;
revoke all on function public.platform_owner_post_ai_agent_message(text, text, text, text, text, text, text, text, jsonb) from public, anon, authenticated, service_role;
revoke all on function public.platform_owner_set_research_source_category(uuid, text, boolean) from public, anon, authenticated, service_role;
