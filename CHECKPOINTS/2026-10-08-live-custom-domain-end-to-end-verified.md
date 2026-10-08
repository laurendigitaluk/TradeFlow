# TradeFlow — LIVE Subscriber-Owned Domain Acceptance Checkpoint — 2026-10-08

## Status

**VERIFIED LIVE — first complete real subscriber-owned custom-domain workflow.**

This checkpoint records the verified state after the successful Adventure Outpost / SceneSource domain test. It is the restore/reference point for the next domain test.

## Verified test

- Subscriber: Adventure Outpost
- Hostname: www.scenesource.co.uk
- LIVE TradeFlow platform: https://tradeflow.laurendigital.co.uk
- Final domain state: **Active · Primary**
- Subscriber Website URL page: **Domain active. Your published TradeFlow website is connected to this domain.**
- Platform Owner Dashboard after activation: **No open subscriber domain connection requests.**

## Seven-phase owner workflow

1. Review the request — **Completed**
2. Prepare the TradeFlow connection automatically — **Completed**
3. Give the customer the exact DNS instructions — **Completed**
4. Verify DNS — **Completed**
5. Verify SSL / HTTPS — **Completed**
6. Verify tenant routing — **Completed**
7. Activate the domain — **Completed**

Activation was performed through the owner workflow after the verification phases. The domain was not manually marked active.

## DNS and Cloudflare evidence

Verified customer DNS for this test:
- Type: CNAME
- Host/name: www
- Target: customers.laurendigital.co.uk

Verified LIVE Cloudflare routing:
- Existing Worker: tradeflow
- Zone: laurendigital.co.uk
- Route: */*
- Failure mode: Fail closed (block)

The wildcard route resolved the previous 522 for the external customer-owned hostname. The existing Worker was retained; no second Worker was created.

**Future rule:** never assume or invent a DNS target. Use the exact target returned by the approved Cloudflare custom-hostname preparation for the specific domain.

## Defects fixed during this acceptance test

### Owner dashboard authentication
Production commit:
c7f0914e9a8686ba5d6e45e360b765ce0e2662e5

The owner dashboard now explicitly sends the authenticated Platform Owner bearer token to the protected custom-domain preparation function.

### Owner domain-action lookup
Production commit:
03fe258aea835a51e6f68924cc5e49cb09fb71cb

The preparation function now uses the authenticated owner RPC for the domain-action lookup rather than the failing direct table lookup.

### Cloudflare Worker routing
The LIVE Cloudflare wildcard route */* was added to the laurendigital.co.uk zone and points to the existing tradeflow Worker. This fixed the customer-hostname 522 boundary.

### Activation JavaScript
Production commit:
25bbc9c86a5778e5911850c2ad64234696c221f4

The activation handler no longer references the out-of-scope variable m. It reads the current domain-action metadata before enforcing the DNS/SSL/routing checks.

Cloudflare Production deployment:
244d6f94 — Fix LIVE domain activation metadata scope.

## Architecture now locked

### Subscriber side
Subscriber owns the domain and remains responsible for:
- registrar account
- domain ownership
- renewal
- billing
- registrar security
- applying DNS instructions

TradeFlow must never request or store the registrar password.

### Platform Owner side
Owner is responsible for:
- reviewing the request
- preparing the approved connection
- issuing exact DNS instructions
- verifying DNS
- verifying SSL/HTTPS
- verifying tenant routing
- activating only after verification

### Infrastructure
- Existing LIVE tradeflow Worker remains the platform Worker.
- Customer-owned hostnames use the Cloudflare SaaS/custom-hostname architecture.
- The verified zone wildcard route is already present and must not be recreated for the next subscriber.
- Do not manually create customer hostnames unless the approved automation fails and the failure has been diagnosed.
- Do not manually set activation flags or bypass the workflow.

## Next test

The next domain test is a **reuse test**, not an infrastructure rebuild.

Start with a fresh subscriber-owned domain request and prove:
1. subscriber enters the domain;
2. owner receives the request;
3. automatic connection preparation works;
4. exact DNS instruction is generated;
5. subscriber applies DNS;
6. DNS verification works;
7. SSL verification works;
8. tenant routing verification works;
9. activation works;
10. subscriber Website URL changes to Active;
11. public customer-owned hostname serves the correct subscriber website.

Perform one step at a time and capture the first failure if anything breaks.

## Documentation lock

Following every material domain change/test, update:
- AI Operating Manual
- Backend/Owner Manual
- Human/Subscriber Manual
- System Handbook
- Master Roadmap
- a dated checkpoint

The Website Builder remains locked and is not part of this domain test.

## Environment safety

- LIVE remains controlled.
- Do not use db reset against LIVE.
- Do not weaken authentication/RLS to make a domain test pass.
- Do not modify unrelated TradeFlow features during domain testing.
- If a source defect is found, reproduce/fix it in the controlled development/release process and promote the approved change to LIVE.
