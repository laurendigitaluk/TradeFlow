# Retail customer shipping requirement fix — 26 September 2026

## Workflow definition
For a paid TradeFlow retail sale, the customer does not need a shipping label or QR code supplied by TradeFlow. The customer needs shipping/tracking information so they can follow delivery.

## Repair
- Removed the server-side mandatory label/QR validation from `subscriber_save_retail_fulfilment_shipping`.
- Subscriber override shipping now requires a carrier/service and tracking number instead.
- Label and QR remain optional fields and are saved when supplied.
- The fulfilment UI wording now explicitly states that a label/QR is not required for this retail-sale workflow.
- Frontend cache version advanced to `v13`.
- Successful handoff continues to move fulfilment to `dispatched` and queue the `Your order is on its way` notification.

## Scope
This applies to the paid retail fulfilment workflow. It does not change customer trade-in shipping workflows.
