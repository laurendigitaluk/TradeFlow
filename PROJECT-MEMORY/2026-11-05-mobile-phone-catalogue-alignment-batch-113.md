# Project Memory — Mobile Catalogue Alignment Batch 113
Date: 5 November 2026

Reconciled mobile catalogue evidence drift between LIVE and TEST. TEST had one active new-price evidence row attached to an already-retired invalid Pixel 11 128GB master product. Deactivated only the evidence row (1a21bf68-2959-4ade-bfbb-7b0fa33218da, key mobile-new-pixel-11-128gb-mymobiles-20261026) and preserved it for audit. The product remains inactive and unchanged; no invalid 128GB variant was copied to LIVE. Verified zero active evidence rows attached to inactive mobile products in either environment.

Aligned selected metadata differences: Galaxy S22 128GB and iPhone 15 128GB used condition/notes in TEST; Motorola Edge 70 256GB MoneySavingExpert source label/channel/notes in LIVE; Galaxy S23 128GB Idealo channel in TEST; Galaxy Z Fold7 1TB Samsung new-price condition/channel in TEST and matching LIVE row. No price/source URL/evidence type/valuation changes.

Post-write: LIVE and TEST each have 563 active evidence rows attached to active mobile products (267 UK-new / 296 UK-used). LIVE 158 active products / 156 visible / 4 missing used / 0 missing all. TEST 159 active / 156 visible / 5 missing used / 1 missing all. The extra TEST master remains the hidden, unverified iPhone 18 256GB; leave it untouched. All 563 evidence rows match by model, storage variant, evidence type, source URL, observed price, condition and sales channel. Some notes and observed_at timestamps differ slightly and were retained.

Four common used gaps remain: Motorola Edge 70 Plus 8GB/256GB; OPPO Find X10 12GB/256GB; OPPO Find X10 Pro Max 12GB/512GB; OPPO Reno16 F 5G 8GB/256GB. Batch 113 research found no verified direct item-level UK used/refurbished listing for these exact variants. Search-only/categorical leads, opened-never-used and new/sealed offers were excluded. No new evidence rows were added. UK-used remains reference-only and out of automatic valuation. No code/schema/deployment changes.

See CHECKPOINTS/2026-11-05-mobile-phone-catalogue-alignment-batch-113.md.
