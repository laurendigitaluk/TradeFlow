# CONTINUATION — TradeFlow after 2026-10-06 full audit

Resume from checkpoint:
`CHECKPOINTS/2026-10-06-full-live-website-audit-and-legacy-cleanup.md`

The production repository has just been audited and cleaned. Do not reintroduce the retired TradeFlow/Porkbun subscriber domain-purchase workflow, Parcel2Go API shipping, ResellerClub, or unused duplicate dashboard runtimes.

Current LIVE branch is `production`. LIVE Supabase is `gxsrajtqzdjvmceqcpgv5`.

The Website Builder is locked at the 5 October baseline. Preserve it exactly.

The current domain architecture is subscriber-owned domains:
subscriber buys/owns domain → enters hostname → Platform Owner prepares connection → exact DNS → subscriber applies DNS → DNS/SSL/routing verification → active.

`platform-prepare-custom-domain` is the automatic Cloudflare preparation function and is now version-controlled in GitHub.

`laurendigital.co.uk` is the Lauren Digital/TradeFlow infrastructure domain purchased directly through Porkbun. Cloudflare nameserver propagation is currently pending. Do not proceed to SaaS/custom-hostname testing until Cloudflare reports the zone Active.

Before any further change:
1. inspect the current production HEAD;
2. inspect the current LIVE Supabase state;
3. read the latest checkpoint and current manuals;
4. preserve the Website Builder lock;
5. make the smallest necessary change;
6. verify the actual browser/backend result.
