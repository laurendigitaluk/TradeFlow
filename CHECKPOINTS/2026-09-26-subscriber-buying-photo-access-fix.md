# Subscriber buying photographs fix — 26 September 2026

## Issue
The Buying workspace showed “Photographs were supplied but could not be opened” even though customer photographs existed.

## Verified data
For Camerashack tenant `21fca2c5-5da2-4ff6-9f8e-318f9b6277f9`, the buying items have media links and corresponding `media_assets` records in the `tradeflow-media` bucket. The Nikon COOLPIX P1100 item has a linked asset with storage path:
`<tenant>/customer-buying/<buying_item_id>/<file>`.

The bucket is private.

## Root cause
The subscriber Buying page was attempting to generate signed storage URLs directly from the browser. That storage access path was failing with a storage permission error, while the underlying media records and files remained present.

## Repair
Created protected Edge Function:
`subscriber-buying-media`
- JWT required.
- Authenticates the subscriber.
- Verifies active membership in the requested tenant.
- Reads only the requested buying item's media links/assets.
- Uses the service role internally to create 24-hour signed URLs.
- Does not make customer photographs public.

Updated `buying-dashboard.js` to load subscriber buying photographs through this protected function instead of direct browser storage signing.

## Scope
No media records, storage files, buying items or customer data were changed. The repair changes only the secure read path for subscriber viewing.
