# Drone evidence gap count correction — batches 34–38
Date: 2026-11-13
Source of truth: LIVE catalogue_master_products + shared_market_evidence; 541 active visible Drone products.

A label transposition in the batch status messages reversed the group labels New-only and Used-only. The missing-type totals were correct. Correct group breakdowns:
| After batch | Neither | UK New only | UK Used only | Both | Missing UK New | Missing UK Used |
|---|---:|---:|---:|---:|---:|---:|
| 34 | 182 | 164 | 120 | 75 | 302 | 346 |
| 35 | 182 | 164 | 117 | 78 | 299 | 346 |
| 36 | 182 | 164 | 115 | 80 | 297 | 346 |
| 37 | 182 | 164 | 112 | 83 | 294 | 346 |
| 38 | 182 | 164 | 110 | 85 | 292 | 346 |

Current: 541 active visible; 182 neither; 164 New-only; 110 Used-only; 85 both. Missing UK New 292 = 182 neither + 110 Used-only. Missing UK Used 346 = 182 neither + 164 New-only. Integrity failures 0. Batch imports, evidence IDs, prices and product master mappings are unchanged. TEST, Stripe, valuation and deployments untouched.
