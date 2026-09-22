# Checkpoint — Shipping handoff publish repair

22 September 2026

The accepted-sale shipping handoff was still showing the send-label state after the subscriber clicked the publish button. The direct acquisition PATCH path was replaced with a SECURITY DEFINER subscriber RPC.

New RPC: `public.subscriber_publish_shipping_handoff`

It:
- checks the authenticated subscriber has `acquisitions.manage` for the tenant;
- validates manual versus integrated shipping;
- writes shipping label, QR, carrier, service, tracking and instructions;
- writes the selected integrated provider and connection;
- sets the appropriate shipping status;
- records `posted_at` for manual shipping;
- atomically moves an accepted acquisition to `awaiting_item`;
- returns the resulting acquisition id/status;
- is executable only by authenticated users.

The Buying and Acquisition dashboards now call this RPC rather than directly PATCHing the acquisition for the publish/send action.

Cache versions:
- Buying Dashboard v24
- Acquisition Dashboard v11

The test acquisition was inspected after the failed click and was still `awaiting_item` with all shipping fields null, confirming the previous publish had not persisted.

Customer Portal remains customer-owned/authenticated and customer shipping remains customer-paid.