# LIVE Metal-detector source coverage checkpoint — 8 November 2026

## Environment
- LIVE only: gxsrajtqzdjvmceqcpgv (eu-west-2).
- TEST not modified; LIVE remains authoritative.

## Verified position
- Active metal-detector products: 125.
- Active products without active market evidence: 32.
- Enabled metal-detector sources after update: 11.

## Sources added
1. Nokta UK Store — UK GBP product catalogue.
2. LP Metal Detecting UK — UK distributor/retailer for Nokta, Minelab, XP, Garrett and Quest.
3. Crawfords Metal Detectors UK — UK product pages for XP, Nokta, Garrett, Quest, Teknetics and Minelab.
4. Detecnicks UK Used Detectors — used/ex-demo-only source lane; retain condition and availability.
5. Detector Distribution UK — UK authorised dealer listings for XP, Garrett and Nokta.

Official dealer validation: Nokta's UK dealer directory lists LP Metal Detecting, Unearthed, Spin a Disc, Regton, Detecnicks and Crawfords. XP's official reseller network lists UK dealers including Crawfords, Detecnicks, Regton and Spin a Disc. Garrett identifies Regton as UK & Ireland distributor.

## Evidence handling
- New UK GBP listings remain in new_uk.
- Detecnicks second-hand listings remain in used_uk only.
- Use inc-VAT consumer GBP when both ex-VAT and inc-VAT are displayed.
- Separate detector-only products from bundles, coils, pinpointers, headphones and accessories.
- Confirm used condition and listing availability before approval.

## Verification and safety
- 5 source rows inserted; 11 enabled category-scoped sources total.
- 125 active products; 32 without active evidence (unchanged).
- No product/evidence rows changed, no task queued, no worker restarted, no TEST data changed.
- Supabase activity record owner-live-metal-detector-source-coverage-20261108 inserted and verified.

## Next
Continue source coverage in categories with active evidence gaps, then verify the installed Research PC commit and complete coordinated agent acceptance. No full Gemma run until gates pass.
