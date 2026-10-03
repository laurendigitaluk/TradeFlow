# TradeFlow Master Catalogue Restoration — 3 October 2026

TEST now has the verified TradeFlow-owned master catalogue: 32 categories, 177 branches, 73 manufacturers, 3,845 master products and 108 identifiers. 3,822 are active/customer-visible.

The LIVE fault was traced to both missing master catalogue rows and an incomplete Supabase endpoint in the LIVE buying-catalogue.js. A natural-key version-controlled restoration was created in migrations 20261003210000 through 20261003210009. The migrations were applied to TEST first and verified idempotent, then promoted to LIVE. No tenant/customer/test transaction data was copied.

Current status: TEST verified; LIVE database applied; LIVE frontend endpoint corrected; LIVE browser verification pending.
