# TradeFlow Current Project Memory — 2026-10-06 Audit

The authoritative working model is now subscriber-owned domains only. TradeFlow does not register, renew or pay for subscriber domains. The old TradeFlow/Porkbun purchase flow is retired.

The LIVE Website Builder baseline from 2026-10-05 is locked and must be preserved.

Shipping is manual subscriber-managed shipping. Parcel2Go API shipping is retired.

LIVE owner domain connection uses a seven-phase workflow and automatic Cloudflare preparation through `platform-prepare-custom-domain`.

The production source tree was cleaned on 2026-10-06 of retired domain-purchase frontend/source, Parcel2Go/ResellerClub source and unused duplicate dashboard runtimes. Historical checkpoints remain for audit history.

`laurendigital.co.uk` is the Lauren Digital/TradeFlow infrastructure domain and has been purchased directly through Porkbun. Cloudflare nameserver propagation is currently pending.

Next infrastructure step after Cloudflare becomes Active: configure and verify the actual fallback/origin and SaaS CNAME target, store real values server-side, then test the automatic customer-domain preparation flow.
