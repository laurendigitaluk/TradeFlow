# Developer Diagnostic Roadmap — Inventory Duplicate Serial Warning

## Scope
TradeFlow TEST only. This roadmap changes the inventory serial-number policy so a duplicate serial number is a warning/review condition rather than a database hard stop.

## Root cause
The Selling page previously performed a pre-save duplicate serial lookup, but the inventory serial index was UNIQUE. A subscriber entering a serial already held by another inventory asset therefore could not save the listing.

## Required behaviour
1. Serial numbers remain optional.
2. When a subscriber enters a serial already assigned to another inventory asset in the same tenant, Selling must show a clear warning.
3. The warning identifies the existing asset reference and title where available.
4. The subscriber must explicitly choose **CONTINUE WITH SERIAL NUMBER** to proceed.
5. Changing the serial number clears the previous confirmation.
6. The database must permit duplicate serial values so legitimate repeated/matching serials can be recorded.
7. The serial lookup index remains for fast tenant-scoped duplicate detection.
8. Duplicate serials remain a review/risk condition; they must not silently be treated as proof that two records are the same physical asset.

## Implementation
- TEST migration: 20260930232732_allow_duplicate_inventory_serial_numbers_with_warning
- Drop the unique partial index and recreate it as a normal partial index.
- Selling JS commit: 5889991fe480d7ad287613ec20c6b62ab9db966a
- Selling HTML/cache commit: 82587c3384eecb3ed89c62afab4cb59aab2e0456
- Browser cache: selling-dashboard-fixed.js?v=69

## Verification
- TEST index is now non-unique.
- TEST migration history contains the baseline plus the new serial-policy migration.
- Existing TEST serial data contains no duplicate tenant/serial groups.
- Code contains the warning, explicit continuation label, and confirmation reset when the serial changes.

## Browser test
Use the Selling workspace with an inventory asset that has a serial already present on another asset:
1. Enter the duplicate serial.
2. Click SEND TO WEBSITE.
3. Confirm the warning appears and publishing stops.
4. Confirm the button changes to CONTINUE WITH SERIAL NUMBER.
5. Click CONTINUE WITH SERIAL NUMBER.
6. Confirm the listing saves and the inventory asset retains the serial.
7. Edit the serial to a different value and confirm the continuation state resets.

Do not alter LIVE/production during this test.
