# Orders workspace permission repair — 2026-09-28

## Problem
The subscriber Orders workspace was stuck at “Loading orders…” and then reported: permission denied for table retail_orders.

## Root cause
orders-dashboard.js was querying public.retail_orders directly through PostgREST. The table is intentionally protected by tenant-scoped RLS. The subscriber owner had the required orders.view permission and the TradeFlow plan had module.orders enabled, but the browser was still attempting direct table access.

## Repair
Added live and repository-backed public.subscriber_get_orders(uuid).

The RPC requires authentication, active tenant membership, orders.view, and module.orders. It returns only rows for the requested tenant, is SECURITY DEFINER, uses an empty search_path, and grants EXECUTE to authenticated users.

Updated orders-dashboard.js to use the RPC instead of directly querying retail_orders.

## Files
- orders-dashboard.js — commit 764eebb275af022e5046db0a88941d289f4c8e30
- supabase/migrations/20260928090000_add_subscriber_get_orders_rpc.sql — commit ab9c4eb169a4d4d2a67ec311340c55611fa98f8a
- Orders page remains on orders-dashboard.js?v=3.

## Expected result
The Orders workspace should load tenant orders, including completed orders, rather than failing on direct table permissions.

No order data was modified or deleted.
