# Original Nintendo Switch controller catalogue — Batch 19

Date: 5 November 2026
Repository: laurendigitaluk/TradeFlow (main)

## Additions
Three CRKD NEO S variants added independently to LIVE and TEST with active UK-new GBP price evidence at £39.99 from the Idealo UK comparison snapshot dated 30 October 2026 08:10 UTC:
- Splatter POPeART: https://www.idealo.co.uk/compare/204670657/crkd-neo-s-splatter-popeart-edition.html
- Atomic Red: https://www.idealo.co.uk/compare/204670659/crkd-neo-s-atomic-red-edition.html
- Emerald Green: https://www.idealo.co.uk/compare/204670660/crkd-neo-s-emerald-green-edition.html

CRKD official NEO S pages confirm Nintendo Switch compatibility. Idealo shows UK GBP prices but does not confirm current stock for these individual variants; availability is recorded as "Price listed; stock not confirmed". Do not present them as confirmed in-stock. Duplicate preflight found no matching package keys; existing CRKD manufacturer rows reused.

## LIVE IDs
- Splatter POPeART product/evidence: 1d39bf99-b6fd-4d91-bbc9-25b7511a67dd / 58c15442-6c57-4d8e-af8e-59e798e3152d
- Atomic Red product/evidence: edbf2936-c65b-437b-8ed8-923d23ec10a1 / 62ae4c1f-bfbe-4c19-80c2-8d8d58fb26e8
- Emerald Green product/evidence: cc3538ad-119d-4ff7-93d7-ae51f4657994 / 40293a66-11be-4815-9b94-f6ec2c7d7252

## TEST IDs
- Splatter POPeART product/evidence: 82b22201-e4cb-4344-9494-af61ecb9f26e / 851a7921-9ac9-4c52-9ed8-aeaf42544bc9
- Atomic Red product/evidence: b852df42-a66e-4d9c-bdf9-bd9778050c45 / 61ac340c-e38c-4ae0-bbf9-2930bd26a7a2
- Emerald Green product/evidence: c24b0c65-998d-4a09-83e4-bafa54c18a6c / a520665e-2721-4ca2-8d27-9629efabcaaa

## Verification
- LIVE: 95 active customer-visible products / 98 active evidence rows.
- TEST: 95 active customer-visible products / 98 active evidence rows.
- Both environments: zero visible products missing active evidence, zero duplicate active evidence source keys and zero invalid active evidence.
- Package keys, prices, source URLs, evidence types and currencies match across environments.
- Prices are advertised marketplace asking prices, not completed sales; observed_at and stock qualification reflect the 30 October Idealo snapshot.

No application code, schema, valuation logic, RLS, Edge Functions, Stripe or tenant/customer/order/payment/custom-domain data changed. No Worker deployment required. Used evidence remains reference-only and does not affect automatic valuation.
