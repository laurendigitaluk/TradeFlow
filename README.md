# TradeFlow

## Customer Test Lab

This repository currently contains the TradeFlow backend foundation and a temporary Customer Test Lab used for authenticated security testing.

### Test tenants
- Customer A → TradeFlow Test Business A (`test-business-a`)
- Customer B → TradeFlow Test Business B (`test-business-b`)

The test-lab onboarding function only permits accounts to attach to tenants explicitly marked as test tenants. It does not grant staff or owner membership.

### Run the test lab

1. Enable GitHub Pages for this repository using the `main` branch and repository root.
2. Open the resulting GitHub Pages site.
3. Enter the TradeFlow Supabase publishable key once. It is stored only in the browser's local storage.
4. Create Customer A with a dedicated test email and password and select **Customer A — Test Business A**.
5. Sign out.
6. Create Customer B with a different test email and password and select **Customer B — Test Business B**.
7. Use the two accounts for the authenticated tenant-isolation tests.

Do not use real customer data in the test tenants.

The Customer Test Lab is temporary test infrastructure and must be removed/replaced by the proper production customer registration flow before TradeFlow goes live.
