# TradeFlow LIVE — Scheduled market-evidence research batch 11

**Research date:** 2026-11-12  
**Repository:** `laurendigitaluk/TradeFlow`  
**Branch:** `production`  
**Environment:** LIVE only  
**Batch size:** 20 products  
**Status:** Research captured; pending-review staging blocked by owner authentication

## 1. Selection and exclusion audit

Before selection, read the scheduled research checkpoints from batch 02 through batch 10 and the available corresponding PROJECT-MEMORY files (02, 04, 05, 06, 07, 08, 09 and 10). Batch 03 checkpoint was present and read; a batch-03 PROJECT-MEMORY file was not present in the production directory. The batch-08 project memory explicitly identified a cross-UUID duplicate identity for Nikon Ai-S NIKKOR 28mm f/2; that model identity was excluded as well as checkpoint UUIDs.

The selection query:
- Collected UUIDs appearing in all scheduled checkpoints batch 02–10.
- Excluded all active `shared_market_evidence` rows.
- Excluded outstanding LIVE queue candidates by linked product ID and manufacturer/model identity.
- Excluded product IDs in outstanding manual AI research prompts.
- Excluded the Nikon Ai-S NIKKOR 28mm f/2 cross-UUID duplicate identity.
- Selected the next 20 active LIVE catalogue products in stable catalogue creation order; **no fixed SQL OFFSET** was used.

LIVE queue snapshot before selection: 10 outstanding `needs_research` candidates; the imported/rejected rows were not treated as outstanding. One outstanding manual AI research prompt contained 20 product IDs. Products covered by either source were excluded.

The 20 selected products were rechecked immediately before research. Each returned:
- active shared evidence: **0**
- outstanding matching LIVE queue candidate: **0**
- outstanding matching manual AI prompt: **0**

A second status recheck after research confirmed all 20 still had zero active evidence, zero matching outstanding queue candidates and zero matching outstanding manual prompts.

## 2. Product research

All prices below are source-displayed GBP prices only. Non-GBP prices are kept in their original currency; no currency conversions have been made. Sold-out, ended, imported, unverified and variant-mismatched listings are retained with explicit notes. Research date for all observations: 2026-11-12.

### 1) Nikon COOLPIX P900
- **LIVE master product ID:** `d28a86d7-5272-4216-984b-a9cbed156288`
- **Catalogue package:** COOLPIX P900
- **Evidence:** Cash Generator displays **£299.99**, in stock, pre-owned Grade B; unboxed, carry bag and battery charger included. MPB shows 12 used examples from **£319–£494**. LCE shows **£349.99**, good condition, in store with strap, battery, charger and charging cable. Clifton search result showed **£449.00**, Excellent, unboxed, one available, three batteries/manual/strap/USB/lens cap; the direct page returned 404 when opened.
- **Sources:**
  - Cash Generator exact listing: https://cashgenerator.co.uk/products/nikon-coolpix-p900-digital-camera
  - MPB used range: https://www.mpb.com/en-uk/product/nikon-coolpix-p900
  - LCE used listing: https://www.lcegroup.co.uk/Used/Nikon-Coolpix-P900_496299.html
  - Clifton listing (page now 404): https://www.cliftoncameras.co.uk/used-nikon-coolpix-p900-14218217
  - Google Shopping Amazon lead: https://www.amazon.co.uk/Nikon-COOLPIX-Digital-Camera-Optical/dp/B00U2W4JEY?source=ps-sl-shoppingads-lpcontext&ref_=fplfs&psc=1&smid=A1I3MOB3UIJVAB
- **RED VERIFY:** Google Shopping showed £1,131.49 against an Amazon UK marketplace offer and a second Ubuy offer; this is far above UK used-market references. Check seller, condition, dispatch and whether the Amazon page is an old/marketplace offer. Do not use that Shopping price as the normal UK market price.

### 2) Nikon COOLPIX S6900
- **LIVE master product ID:** `9a79d3f8-7a66-42a5-bf13-5b6dc243c9bf`
- **Catalogue package:** COOLPIX S6900
- **Evidence:** eBay UK marketplace listings from Japan display **£362.28** (used; seller notes scratches/dirt and yellowing on right side of screen), **£298.93** (used but lens error present; seller says tested, but item has a fault), and further Shopping offers **£255.68**, **£252.99** and **£358.59**. These are Japan-based seller offers; shipping/import and item condition vary.
- **Sources:**
  - £362.28 listing: https://www.ebay.co.uk/itm/187773557522
  - £298.93 lens-error listing: https://www.ebay.co.uk/itm/377330937492
  - £255.68 Shopping lead: https://www.ebay.co.uk/itm/137697629307?chn=ps&_ul=GB&mkevt=1&mkcid=28&google_free_listing_action=view_item
  - £252.99 Shopping lead: https://www.ebay.co.uk/itm/147559466322?chn=ps&_ul=GB&mkevt=1&mkcid=28&google_free_listing_action=view_item
  - £358.59 Shopping lead: https://www.ebay.co.uk/itm/389474903871?chn=ps&_ul=GB&mkevt=1&mkcid=28&google_free_listing_action=view_item
- **RED VERIFY:** All visible leads are Japan-based marketplace offers, not verified UK domestic stock. The £298.93 listing explicitly has a lens error and must not be treated as a working-camera price. Check import charges, voltage/plug notes and exact condition on each item.

### 3) Nikon COOLPIX S7000
- **LIVE master product ID:** `f76e717f-4bba-422f-92b3-09aa6cb3d4bb`
- **Catalogue package:** COOLPIX S7000
- **Evidence:** Kamerastore displays **£158.00 GBP**, certified used and in stock online; staff notes moderate display wear and minor body wear, otherwise good working condition. UK Google Shopping/marketplace results include eBay offers around **£141.26**, **£154.70**, **£189.15**, **£211.37**, and Amazon marketplace **£209.00**. Buy Any Tech has an exact black S7000 listing in Acceptable condition, but the opened page did not expose a reliable price in the captured page text.
- **Sources:**
  - Kamerastore exact product: https://kamerastore.com/en-gb/products/nikon-coolpix-s7000-t160059
  - UsedLens listing comparison: https://usedlens.co.uk/product/nikon-coolpix-s7000
  - Buy Any Tech exact listing: https://buyanytech.co.uk/product/nikon-s7000-used-acceptable-120348
  - eBay Shopping £141.26: https://www.ebay.co.uk/itm/137433266894?chn=ps&_ul=GB&mkevt=1&mkcid=28&google_free_listing_action=view_item
  - eBay Shopping £154.70: https://www.ebay.co.uk/itm/800741873736?chn=ps&_ul=GB&mkevt=1&mkcid=28&google_free_listing_action=view_item
  - eBay Shopping £189.15: https://www.ebay.co.uk/itm/407257575374?chn=ps&_ul=GB&mkevt=1&mkcid=28&google_free_listing_action=view_item
  - eBay Shopping £211.37: https://www.ebay.co.uk/itm/860107224770?chn=ps&_ul=GB&mkevt=1&mkcid=28&google_free_listing_action=view_item
  - Amazon Shopping £209: https://www.amazon.co.uk/Nikon-Coolpix-Compact-Camera-White-Megapixel/dp/B0F5MSHW8T?source=ps-sl-shoppingads-lpcontext&ref_=fplfs&psc=1&smid=AV2WZD50N07UF
- **Notes:** Kamerastore states duties/taxes are calculated at checkout and UK shipping starts from £8.50. Shopping prices are seller/condition-specific; several are overseas sellers. Check exact colour, accessories and delivery origin.

### 4) Nikon NIKKOR Z 26mm f/2.8
- **LIVE master product ID:** `cbb584bc-65d7-4cb1-bc3d-019ea3556042`
- **Catalogue package:** NIKKOR Z 26mm f/2.8
- **Evidence:** Nikon UK official store **£449.00** (was £499.00), in stock, delivery 3–5 business days. Included box items: rear cap LF-N1, hood HB-111 and lens cap LC-K108. Castle Cameras search result showed **£494.00**; later direct page title rendered £444.00, so that retailer price is inconsistent. Camera Centre shows **£494.00**, in stock. Bass & Bligh shows **£449.00**, new, only two left. Bristol Cameras shows **£489.00 inc VAT**, available to order. Norwich Cameras shows **£387.00**, stock available with 5–7 day lead time, but seller is Futronix Electronic Limited (Hong Kong) and listing says no VAT.
- **Sources:**
  - Nikon UK official: https://www.nikon.co.uk/en_GB/product/lenses/mirrorless/nikkor-z-26mm-f2.8-JMA108DA
  - Castle Cameras: https://www.castlecameras.co.uk/nikon-nikkor-z-26mm-f28-lens/p16647
  - Camera Centre: https://www.cameracentreuk.com/nikon-z-26mm-f2-8-fx-lens
  - Bass & Bligh: https://bassandbligh.com/products/nikon-z-26mm-f-2-8
  - Bristol Cameras: https://www.bristolcameras.co.uk/product/nikon-z-26mm-f2-8-nikkor-pancake-lens/
  - Norwich Cameras: https://norwich-cameras.co.uk/products/nikon-nikkor-z-26mm-f-2-8-lens
  - Google Shopping Ubuy lead: https://www.u-buy.co.uk/productjp/FBV1HYIVK-nikon-nikkor-z-26mm-f-2-8-z-mount-single-focus-lens-full-size-black
  - Google Shopping Viltrox wrong-model lead: https://www.ebay.co.uk/itm/366735540217?chn=ps&_ul=GB&mkevt=1&mkcid=28&google_free_listing_action=view_item
- **RED VERIFY:** Castle price differs between its search result and opened page. Norwich's lower offer is a Hong Kong-supplied product with no VAT; verify seller/dispatch and VAT treatment. Shopping also returned Viltrox 26mm f/2.8 EVO lenses, which are not the Nikon NIKKOR Z 26mm; do not match those.

### 5) Nikon NIKKOR Z 50mm f/1.4
- **LIVE master product ID:** `beb389f1-c53e-4166-9cf6-2b07148df339`
- **Catalogue package:** NIKKOR Z 50mm f/1.4
- **Evidence:** Nikon UK official store **£449.00** (was £499.00), in stock, free delivery in 3–5 business days. Included items: LC-62B front cap, LF-N1 rear cap and HB-115 hood. Clifton Cameras also shows **£449.00**, but says awaiting stock, normally 5–7 days. Google Shopping results showed Cameriz **£331.00**, CamerasDori **£325.00**, and Cash Converters **£359.98** pre-order.
- **Sources:**
  - Nikon UK official: https://www.nikon.co.uk/en_GB/product/lenses/mirrorless/nikkor-z-50mm-f1.4_1-JMA004DA
  - Clifton Cameras: https://www.cliftoncameras.co.uk/nikon-nikkor-z-50mm-f14-lens
  - Cameriz Shopping result: https://cameriz.com/products/nikon-z-50mm-f-1-4-lens?currency=GBP&country=GB&variant=52917271265609
  - CamerasDori Shopping result: https://camerasdori.com/product/nikon-nikkor-z-50mm-f-1-4-lens
  - Cash Converters pre-order: https://www.cashconverters.co.uk/shop/phones-cameras--computers/cameras/lenses--filters/camera-lens/021200258131
- **RED VERIFY:** Cameriz/CamerasDori prices are materially below Nikon's own UK price. Verify seller identity, dispatch origin, VAT and stock before relying on those figures. Clifton has stock wording that says awaiting stock despite the product price.

### 6) Nikon Ai-S Nikkor 800mm f/8 ED
- **LIVE master product ID:** `f18c9245-7b41-4da4-80c6-4175f2812500`
- **Catalogue package:** Standard
- **Evidence:** Exact Ai-S ED NIKKOR 800mm F8 Shopping/eBay result from rebirth_japan displayed **£618.29**; the merchant link could not be opened directly, so the user should check it. Another exact eBay search result displayed **£1,251.06** from a Japan-based private seller; when the ended page was opened it displayed £1,106.33 and showed the listing had ended on 8 October. Gumtree shows **£1,200** for a used Nikon ED800 f/8 IF in good condition with case/manual, but exact Ai-S designation is not confirmed.
- **Sources:**
  - Google Shopping exact-title lead (eBay): https://www.ebay.co.uk/itm/237096514182?chn=ps&_ul=GB&mkevt=1&mkcid=28&google_free_listing_action=view_item
  - eBay ended listing: https://www.ebay.co.uk/itm/137751101233
  - Gumtree ED800 f/8: https://www.gumtree.com/p/video-camera-accessories/nikon-ed800-f8/1802151322
  - Nikon official Ai Nikkor ED 800mm f/5.6S IF page (different aperture/model): https://nij.nikon.com/products/lineup/nikkor/fmount/ai_nikkor_ed_800mm_f56s_if/
  - Google Shopping wrong f/5.6 Ai-S lens: https://www.ebay.co.uk/itm/168347373072?chn=ps&_ul=GB&mkevt=1&mkcid=28&google_free_listing_action=view_item
- **RED VERIFY:** Check that the £618.29 lead is actually the Ai-S 800mm f/8 ED, not a different 800mm lens. The £1,251.06 Japan listing is ended and its page showed £1,106.33 before buyer-protection presentation. Gumtree's ED800 f/8 IF listing does not confirm Ai-S suffix. Nikon's official page is for an 800mm f/5.6S, not this f/8 product. Do not merge the f/5.6 model into this catalogue product.

### 7) Nikon D60
- **LIVE master product ID:** `d52bf262-7a5b-407c-8066-c548cfc06b24`
- **Catalogue package:** Nikon D60
- **Evidence:** Wex Google Shopping result shows used body-only **£48.99**; MPB Shopping result **£57.95**. CameraPriceBuster lists used body prices from **£44–£69** across Wex/MPB. Cash Generator shows **£79.99**, in stock, pre-owned Grade B, but that is a kit with AF-S DX 18–55mm lens, charger and Jessops camera bag. Google Shopping Back Market result **£182.99** also includes the 18–55mm lens.
- **Sources:**
  - Wex used body: https://www.wexphotovideo.com/nikon-d60-digital-slr-camera-body-used-3369837/
  - CameraPriceBuster used body comparison: https://www.camerapricebuster.co.uk/Nikon/Nikon-Digital-SLRs/Nikon-D60-Body/Used
  - Cash Generator kit: https://cashgenerator.co.uk/collections/cameras-photography/products/nikon-d60-camera-18-55mm-lens
  - Back Market lens kit Shopping result: https://www.backmarket.co.uk/en-gb/p/d60-black-nikon-nikon-af-s-dx-nikkor-18-55-mm-f35-56g-ed-ii-f35-56g/0b90ded7-dea2-476d-b033-9f208195a39a
  - eBay D60 + spare battery/charger Shopping result: https://www.ebay.co.uk/itm/335949838930?chn=ps&_ul=GB&mkevt=1&mkcid=28&google_free_listing_action=view_item
- **Notes:** Keep body-only and 18–55mm kit evidence separate. The Cash Generator item is available in stock at Stretford, Grade B, with charger and bag.

### 8) Nikon Df
- **LIVE master product ID:** `c0bc4183-fd65-44b7-9cec-5aa1309c542e`
- **Catalogue package:** Nikon Df
- **Evidence:** MPB shows five used bodies from **£899–£1,189**. A specific MPB Excellent body is **£1,089**, shutter count 6,938, with battery, charger, strap, eyepiece and body cap, 12-month warranty. LCE shows **£699.99**, average condition, shutter count 32,000, boxed with shown accessories, six-month warranty, in store at Derby. Google Shopping also surfaced eBay **£700.25** and SLRHut **£1,784.00**.
- **Sources:**
  - MPB used range: https://www.mpb.com/en-uk/product/nikon-df
  - MPB exact Excellent listing: https://www.mpb.com/en-uk/product/nikon-df/excellent
  - LCE used listing: https://www.lcegroup.co.uk/Used/Nikon-Df-Body-_492648.html
  - eBay Shopping lead: https://www.ebay.co.uk/itm/267757234730?chn=ps&_ul=GB&mkevt=1&mkcid=28&google_free_listing_action=view_item
  - SLRHut Shopping lead: https://slrhut.co.uk/item-1505c5-view
  - York Camera Mart Shopping lead: https://yorkcameramart.co.uk/product/used-nikon-df-body-mirrorless-camera/
- **RED VERIFY:** Check the £1,784 SLRHut result and whether its price includes any accessories or is a seller/import issue. LCE is an in-store used body; confirm the item is still available before using the £699.99.

### 9) Nikon EM
- **LIVE master product ID:** `cd2ba8f1-38c6-4b3c-b022-a2035d017b7f`
- **Catalogue package:** Nikon EM
- **Evidence:** Film Camera Store exact body-only page displays **£119.99 GBP**, but the product is explicitly **backordered** and will ship when back in stock. No reliable current UK in-stock price was established.
- **Source:** https://filmcamerastore.co.uk/collections/nikon/products/nikon-em-35mm-slr-film-camera-body-only
- **Notes:** Price is useful as a retailer asking-price reference, not an available-now offer. Google Shopping surfaced Nikon FE listings, which are a different model and were not matched.

### 10) Nikon F2 Data
- **LIVE master product ID:** `f1fa15d0-e197-4626-9906-c1aba316f75a`
- **Catalogue package:** Nikon F2 Data
- **Evidence:** Exact Yahoo Japan auction titled Nikon F2 Data Back MF-10; ended in 2023, condition scratches/dirt, operation not confirmed. Search result displayed **¥79,000** (JPY). CameraWorth's F2 AS Data record refers to the MF-10/MF-11 data-back variant and one historical 2005 auction; the auction source amount is **€1,430**. CameraWorth also displays a converted £978 figure; **do not use that converted GBP value**. No reliable UK GBP price found.
- **Sources:**
  - Exact Yahoo auction: https://auctions.yahoo.co.jp/jp/auction/l1115301254
  - F2 AS Data historical record: https://www.cameraworth.com/n/nikon/f2-as-data/
  - Ffordes generic F2 Photomic body-only (not Data): https://www.ffordes.com/p/SH-24-093831/nikon-manual/nikon/f2-photomic-black-body-only
  - eBay F2 with OxBerry copy back (not MF-10/MF-11 Data): https://www.ebay.co.uk/itm/187290018994
  - Mifsuds F2S Photomic DP-2 (not Data): https://mifsuds.com/product/used-nikon-f2s-photomic-with-dp-2-prism-black-st41408/
- **RED VERIFY:** Catalogue identity should be checked against Nikon F2AS Data (DP-12 prism) and the MF-10 or MF-11 data back. Do not substitute a standard F2 Photomic or a copy back. Keep ¥79,000 and €1,430 in original currencies only; no GBP conversion.

### 11) Nikon NIKONOS V
- **LIVE master product ID:** `d4b470e7-8ba4-4c3a-895a-448832b04b11`
- **Catalogue package:** NIKONOS V
- **Evidence:** Kamerastore **£306.00 GBP**, certified used and in stock; staff notes say working but waterproofing has not been tested. eBay UK body-only listing showed **£120.00**, used, private seller in Ulverston, but the listing ended by seller and was not confirmed sold. Another eBay listing sold for **£199.99** with 28mm f/3.5 lens, a different package. Google Shopping surfaced additional eBay camera/lens packages around £156.70 and £271.39.
- **Sources:**
  - Kamerastore exact camera: https://kamerastore.com/en-gb/products/nikon-nikonos-v-nikonos-t118366
  - eBay UK body-only ended listing: https://www.ebay.co.uk/itm/158177219934
  - eBay sold camera + 28mm lens: https://www.ebay.co.uk/itm/389093267992
  - Google Shopping camera/lens listing: https://www.ebay.co.uk/itm/227519824508?chn=ps&_ul=GB&mkevt=1&mkcid=28&google_free_listing_action=view_item
  - Google Shopping alternate body/lens offer: https://www.ebay.co.uk/itm/920083019341?chn=ps&_ul=GB&mkevt=1&mkcid=28&google_free_listing_action=view_item
- **RED VERIFY:** Waterproofing must be tested before treating the Kamerastore item as a fully functional underwater camera. Keep body-only and lens-kit prices separate. The £120 listing ended by seller, not confirmed sold.

### 12) Nikon PC-E Nikkor 24mm f/3.5D ED
- **LIVE master product ID:** `a9ac4511-d7bb-4ea7-a12b-fb2d5aca9735`
- **Catalogue package:** Nikon PC-E Nikkor 24mm f/3.5D ED
- **Evidence:** MPB exact used model shows six items from **£219–£639**: £219 is explicitly spares/repairs; £384 Good; £534 Good; £639 Like New. Google Shopping Wex result **£659**; Ace Optics used **£699**; eBay leads **£799** and **£909.43**. Google Shopping also surfaced a **£68** LensPimp lead and a CameraWorld £2,099 lead.
- **Sources:**
  - MPB exact used range: https://www.mpb.com/en-uk/product/nikon-pc-e-nikkor-24mm-f-3-5d-ed
  - Wex used lead: https://www.wexphotovideo.com/nikon-24mm-f3-5d-ed-pc-e-lens-used-3366021/
  - Ace Optics used: https://www.aceoptics.co.uk/used-nikon-24mm-f3-5d-pc-e.html
  - eBay £799 lead: https://www.ebay.co.uk/itm/127311766441?chn=ps&_ul=GB&mkevt=1&mkcid=28&google_free_listing_action=view_item
  - eBay £909.43 Shopping lead: https://www.ebay.co.uk/itm/920107003539?chn=ps&_ul=GB&mkevt=1&mkcid=28&google_free_listing_action=view_item
  - LensPimp Shopping lead: https://lenspimp.com/product/Nikon_24mm_f35D_ED_PC-E/
- **RED VERIFY:** The £219 MPB item is spares/repairs, not a working-lens price. The £68 LensPimp Shopping result is a major outlier; open and check whether it is a real lens, accessory, deposit or erroneous listing before relying on it. The CameraWorld £2,099 Shopping price also needs variant/stock verification.

### 13) Panasonic Leica DG Vario-Elmarit 50-200mm f/2.8-4 ASPH. Power O.I.S.
- **LIVE master product ID:** `9c1536a0-5002-4aff-a192-6a8ac8d193f7`
- **Catalogue package:** Standard
- **Evidence:** Google Shopping Cotswold Cameras **£1,034.00**; Cameriz **£957.00**; CamerasDori **£989.00**; Norwich Cameras **£1,065.00**; Kamerastore **£903.50** (used/certified listing); eBay **£856.75** (near-mint seller listing). Camix direct page currently displays **£1,230** (was £1,475; £1,025 ex VAT), with conflicting “Awaiting Stock” and “In stock – Order NOW” messages.
- **Sources:**
  - Cotswold Cameras Shopping result: https://www.cotswoldcameras.co.uk/Panasonic-50-200mm-f-28-40-LEICA-DG-VARIO-ELMARIT-POWER-OIS-Lens
  - Camix direct page: https://camix.co.uk/product/panasonic-leica-dg-vario-elmarit-50-200mm-f-2-8-4-asph-power-o-i-s-lens/
  - Cameriz Shopping result: https://cameriz.com/products/panasonic-leica-dg-vario-elmarit-50-200mm-f-2-8-4-asph-power-o-i-s-lens?currency=GBP&country=GB&variant=52766241947977
  - Kamerastore used lead: https://kamerastore.com/en-gb/products/panasonic-50-200mm-f-2-8-4-leica-dg-vario-elmarit-asph-power-o-i-s-h-es50200-micro-four-thirds-t135955
  - eBay Shopping lead: https://www.ebay.co.uk/itm/407282797839?chn=ps&_ul=GB&mkevt=1&mkcid=28&google_free_listing_action=view_item
  - Norwich Cameras lead: https://norwich-cameras.co.uk/products/panasonic-leica-dg-vario-elmarit-50-200mm-f-2-8-4-asph-power-o-i-s-lens
- **RED VERIFY:** Verify stock on Camix because the same page shows both awaiting stock and in-stock wording. Norwich's seller is Futronix Electronic Limited (Hong Kong) and the price may exclude VAT; verify UK delivery and VAT. Keep used and new listings separate.

### 14) Panasonic Lumix DC-FZ1000 II
- **LIVE master product ID:** `af3f3ed9-ad6c-4aad-9015-2de49810e0b2`
- **Catalogue package:** Standard
- **Evidence:** Currys price shown via Thamez **£749.00**, 7 left, 1–3 days, £5.99 UK delivery. Kamerastore **£759.00**, certified used and in stock; staff notes say zoom is slow/unresponsive using the lever, viewfinder scratched, minor external wear. LCE search result showed **£699.99**, used, boxed, good condition and six-month warranty, but its opened page now says the used item is no longer available. Google Shopping also surfaced Lifestyle Home Appliance Warehouse **£536.76**, CamerasDori **£629.00**, eBay **£506.50**, and Xdeal **£850.00**.
- **Sources:**
  - Currys offer via Thamez: https://www.thamez.co.uk/dp/panasonic-lumix-dc-fz1000-ii-high-performance-bridge-camera-black-black/5025232892730/
  - Kamerastore exact used listing: https://kamerastore.com/en-gb/products/panasonic-lumix-dc-fz1000-ii-t150535
  - LCE used listing (now removed): https://www.lcegroup.co.uk/Used/Panasonic-LUMIX-FZ1000-II---Boxed_498437.html
  - Lifestyle Home Appliance Warehouse Shopping result: https://lifestylehomeappliancewarehouse.com/product/panasonic-lumix-dc-fz1000-ii-high-performance-bridge-camera-black/
  - Xdeal Shopping result: https://www.xdeal.co.uk/panasonic-lumix-dmc-fz1000-ii-20-1mp-f2-8-f4-lens-black?language=en-gb&currency=GBP
- **RED VERIFY:** Check the low Lifestyle Home Appliance Warehouse offer, seller identity, dispatch, returns and whether the page still allows checkout. The LCE price is historical/removed, not current stock. Kamerastore's zoom lever fault must be retained with the price.

### 15) Panasonic Lumix DMC-GM5
- **LIVE master product ID:** `e2465482-b3d0-47ef-91b1-3aaab59fdf30`
- **Catalogue package:** Standard
- **Evidence:** Wex exact body-only used listing **£759.00**, in stock, Excellent condition, approximately 4,000 shutter count, charger/battery/box and other accessories listed. Another Wex Shopping body-only result **£627.00**. MPB shows eight used items **£624–£769**; some are body-only, some kits/accessory combinations. MPB lens kit **£744.00** includes 12–32mm lens. Google Shopping eBay Japan lead **£848.54**.
- **Sources:**
  - Wex £759 body-only: https://www.wexphotovideo.com/panasonic-lumix-dmc-gm5-body-only-used-3357606/
  - Wex £627 body-only Shopping result: https://www.wexphotovideo.com/panasonic-lumix-dmc-gm5-body-only-used-3359535/
  - MPB used range: https://www.mpb.com/en-uk/product/panasonic-lumix-dmc-gm5
  - MPB lens kit £744: https://www.mpb.com/en-uk/product/panasonic-lumix-dmc-gm5/sku-3888239
  - MPB additional used listing: https://www.mpb.com/en-uk/product/panasonic-lumix-dmc-gm5/sku-3894489
  - eBay Japan Shopping lead: https://www.ebay.co.uk/itm/398437339819?chn=ps&_ul=GB&mkevt=1&mkcid=28&google_free_listing_action=view_item
- **Notes:** Separate body-only and lens-kit packages. The Wex £759 body-only page is in stock; the £627 and MPB records are distinct stock items and may change.

### 16) Pentax HD PENTAX-D FA 28-105mm F3.5-5.6 ED DC WR
- **LIVE master product ID:** `f7316ef4-19e8-4c79-ae52-81d489dc8aad`
- **Catalogue package:** Standard
- **Evidence:** MPB exact model shows three used lenses **£244–£254**, all Excellent, with 12-month warranty and lens hood/caps. Bristol Cameras new listing **£549 inc VAT**, available to order, genuine UK stock. Park Cameras search lead **£629**. 
- **Sources:**
  - MPB used exact model: https://www.mpb.com/en-uk/product/pentax-hd-pentax-d-fa-28-105mm-f-3-5-5-6-ed-dc-wr
  - Bristol Cameras new: https://www.bristolcameras.co.uk/product/pentax-hd-pentax-d-fa-28-105mm-f3-5-5-6-ed-dc-wr-lens/
  - Park Cameras lead: https://www.parkcameras.com/shop/pentax-hd-pentax-d-fa-28-105mm-f35-56-ed-dc-wr-lens
- **Notes:** Keep new and used evidence separate. MPB used stock is exact model and current range; Bristol says available to order, not necessarily physically held.

### 17) Pentax HD PENTAX-D FA MACRO 100mm F2.8 ED AW
- **LIVE master product ID:** `b5057877-c336-4bc8-a13b-55ec7f4c3050`
- **Catalogue package:** Standard
- **Evidence:** Park Cameras exact HD Pentax-D FA Macro 100mm f/2.8 ED AW page **£599.00**. It displays a 20% voucher code PENTAX-20, but page asks for product options/store before adding to basket. Camera Centre search result **£699.00**, in stock. CameraWorld search lead **£630.00**, awaiting stock. Bristol search result **£594.00**, while opened page/search detail showed £699.00.
- **Sources:**
  - Park Cameras exact product: https://www.parkcameras.com/shop/hd-pentax-d-fa-macro-100mm-f28-ed-aw-lens-black_5246101d
  - Camera Centre: https://www.cameracentreuk.com/pentax-hd-d-fa-macro-100mm-f2-8-ed-aw-lens
  - CameraWorld: https://www.cameraworld.co.uk/pentax-hd-pentax-d-fa-macro-100mm-f2-8-ed-aw-lens.html
  - Bristol Cameras search lead: https://www.bristolcameras.co.uk/product/pentax-hd-pentax-d-fa-macro-100mm-f2-8-ed-aw-lens/
- **RED VERIFY:** Park price is visible, but delivery/stock requires selecting options/store; voucher discount should not be calculated into a new price without testing checkout. Bristol search result and page price conflict. Do not attach used Pentax D FA 100mm WR or older SMC FA 100mm listings to this exact HD D FA AW model.

### 18) Pentax O-RC1 Remote Control
- **LIVE master product ID:** `d7cfc8ee-dfa7-40bd-9d4a-f419192db4e6`
- **Catalogue package:** O-RC1 Remote Control
- **Evidence:** Park Cameras exact waterproof remote **£26.99**. SCAN exact manufacturer code 39892 **£29.99**, awaiting ETA/pre-order. Clifton Cameras exact MPN 39892 **£26.00**, awaiting stock, orders accepted, usually 5–7 days. Shopping also surfaced an eBay offer £50.99, but seller's brand/MPN data did not establish an exact Ricoh/Pentax original.
- **Sources:**
  - Park Cameras: https://www.parkcameras.com/shop/pentax-remote-control-o-rc1-waterproof_5340061c
  - SCAN: https://www.scan.co.uk/products/ricoh-pentax-o-rc1-remote-control
  - Clifton Cameras: https://www.cliftoncameras.co.uk/Pentax-O-RC1-Waterproof-Remote-Control
  - Google Shopping generic eBay lead: retain only as an uncertain seller lead; do not use as exact product evidence until brand and manufacturer code are confirmed.
- **Notes:** SCAN and Clifton both show awaiting stock. Park price is exact, but check the selected product/store availability.

### 19) Pentax smc PENTAX-FA 100mm F2.8 Macro
- **LIVE master product ID:** `9cafcfea-c980-435c-bce7-a931311343f5`
- **Catalogue package:** Standard
- **Evidence:** MPB exact SMC Pentax-FA 100mm f/2.8 Macro shows three used lenses **£61 each**, Good condition, front/rear caps, 12-month warranty. eBay Fivercam UK used listing **£234.89** plus **£49.99** shipping. Japan-based eBay used listings **£81.67** and **£108.35**, described near-mint/tested.
- **Sources:**
  - MPB exact model: https://www.mpb.com/en-uk/product/pentax-smc-pentax-fa-100mm-f-2-8-macro
  - eBay UK business seller: https://www.ebay.co.uk/itm/257096058303
  - eBay Japan £81.67: https://www.ebay.co.uk/itm/298582314481
  - eBay Japan £108.35: https://www.ebay.co.uk/itm/298386005620
  - LCE £149.99 different D FA model (not exact): https://www.lcegroup.co.uk/Used/Pentax-D-FA-100mm-F2.8-SMC-Macro_498077.html
- **RED VERIFY:** The LCE listing is a D FA lens, not the older SMC Pentax-FA model; do not match it. The £234.89 eBay listing has £49.99 shipping, so evaluate the total only at checkout. Japan offers have import/shipping considerations.

### 20) Potensic Dreamer 1
- **LIVE master product ID:** `edb9d48c-cdfc-46a6-b09f-d06f4ea00975`
- **Catalogue package:** Standard Package
- **Evidence:** Potensic official launch article from 7 June 2021 identifies the product as DREAMER/Dreamer 4K. Official specs URL on test.potensic.com returned 404. UK FLYDRONE page displays **£254.99** (was £299.99), sold out; package contents listed: Dreamer 4K drone, transmitter with built-in battery, 3000mAh flight battery, AC cable, propeller pair, charger, USB cable and manual. Specs include 4K still images, 2.7K video and up to 31 minutes flight time.
- **Sources:**
  - Potensic official launch article: https://store.potensic.com/blogs/news/potensic-launches-a-brand-new-drone-dreamer
  - Potensic official specs URL (now 404): https://test.potensic.com/dreamer-4K-specs
  - UK FLYDRONE listing: https://gsflydrone.co.uk/products/potensic-dreamer-drones-with-4k-13mp-sony-sensor-camera-gps-rc-quadcopter
  - Potensic official Dreamer 4K help/spec reference: https://store.potensic.com/en-eu/blogs/news/what-you-want-to-know-about-dreamer
- **RED VERIFY:** Catalogue model says “Dreamer 1”; manufacturer identifies “DREAMER” / “Dreamer 4K”. Verify this is the same generation/model before accepting the match. UK retailer listing is sold out; keep £254.99 as a sold-out asking-price reference, not a current available offer. Google Shopping results for Potensic ATOM, ATOM SE and unrelated mini drones were wrong models and must not be attached.

## 3. Google Shopping click-through audit

A 20-product product/Shopping search returned 67 product-result cards. All 67 result refs were opened/attempted individually. Several did not resolve to a merchant page or returned no page; the rest were checked against their product titles/pages. Important mismatches retained above include:
- Nikon Ai-S 800mm **f/5.6** listings — wrong aperture for the catalogue f/8 lens.
- Nikon D60 lens-kit Shopping results — not body-only.
- Viltrox AF 26mm f/2.8 EVO — not Nikon NIKKOR Z 26mm f/2.8.
- Nikon F2 Photomic/eye-level listings — not F2 AS Data with MF-10/MF-11.
- Nikon FE — not Nikon EM.
- Panasonic DMC-FZ1000 first-generation listings — not FZ1000 II.
- Pentax D FA 100mm WR — not the HD D FA Macro 100mm ED AW or older SMC FA 100mm.
- Potensic ATOM/ATOM SE — not Dreamer 1/Dreamer 4K.

No wrong-model Shopping price has been assigned to an exact catalogue product. Links are retained where useful, with RED VERIFY notes.

## 4. Queue staging and owner-auth result

Owner context was checked before any write attempt and rechecked after research:
- `auth.uid()`: **null**
- `auth.role()`: **null**
- `platform_cloud_ai_owner_check()`: **false**

Therefore no authenticated platform-owner RPC can be called in this run. Per instruction:
- No direct write to `platform_catalogue_research_queue`.
- No RLS bypass or claim impersonation.
- **0 of 20 candidates staged** as pending review.
- All 20 research candidates and their source links/notes are preserved here for the next run.
- Uncertain prices have not been added to valuation logic.

The final post-research status recheck returned zero active evidence, zero matching outstanding queue candidates and zero matching outstanding manual prompts for all 20 selected product IDs.

## 5. Next scheduled run

The next scheduled run must read this batch-11 checkpoint and its PROJECT-MEMORY before selection. Exclude all 20 product IDs above, all product IDs in every earlier scheduled checkpoint, any outstanding LIVE research-queue candidate and any outstanding manual AI prompt. Select the next 20 active LIVE products with no active evidence using anti-joins and stable ordering; no fixed SQL OFFSET. Recheck status immediately before research. Check owner-auth first; only use the supported authenticated platform-owner RPC if auth.uid is non-null and owner check succeeds. Otherwise save the next detailed checkpoint and project memory.

**No TEST, Stripe, catalogue master product, schema or valuation changes were made.**


## 6. RED VERIFY follow-up — 12 November 2026

Twelve further exact UK GBP observations were imported into LIVE and read back:

| Master product | Source | Price | Evidence / status |
|---|---|---:|---|
| Nikon COOLPIX P900 | MPB | £319.00 | Used; 12 available from £319–£494; grades/accessories vary. [Source](https://www.mpb.com/en-uk/product/nikon-coolpix-p900) |
| Nikon COOLPIX P900 | London Camera Exchange | £349.99 | Used Good; Winchester, in store, clean optics, working, box/charger/front cap, 6-month warranty. [Source](https://www.lcegroup.co.uk/Used/Nikon-Coolpix-P900_496299.html) |
| Nikon Df body | London Camera Exchange | £699.99 | Used Average; 32,000 shutter count; Derby in-store; main/thumb grips slightly loose; 6-month warranty. [Source](https://www.lcegroup.co.uk/Used/Nikon-Df-Body-_492648.html) |
| Nikon NIKKOR Z 50mm f/1.4 | Nikon UK | £449.00 | New; in stock, reduced from £499; caps and hood included. [Source](https://www.nikon.co.uk/en_GB/product/lenses/mirrorless/nikkor-z-50mm-f1.4_1-JMA004DA) |
| Nikon NIKKOR Z 26mm f/2.8 | Nikon UK | £449.00 | New; in stock, reduced from £499; rear cap, hood and lens cap included. [Source](https://www.nikon.co.uk/en_GB/product/lenses/mirrorless/nikkor-z-26mm-f2.8_1-JMA002DA) |
| Pentax HD D FA 28-105mm f/3.5-5.6 ED DC WR | MPB | £244.00 | Used Excellent; one available, SKU 4178933, caps/hood, 12-month warranty. [Source](https://www.mpb.com/en-uk/product/pentax-hd-pentax-d-fa-28-105mm-f-3-5-5-6-ed-dc-wr) |
| Pentax HD D FA 28-105mm f/3.5-5.6 ED DC WR | SRS Microsystems | £209.00 | Used Excellent; checked/guaranteed, box/caps/hood, 12-month warranty, 30-day approval. [Source](https://www.srsmicrosystems.co.uk/dpt/used-equipment/used-pentax-hd-d-fa-28-105mm-35-56-wr--12-months-warranty__17630) |
| Pentax HD D FA Macro 100mm f/2.8 ED AW | Carmarthen Cameras | £699.99 | New black, two in stock, ready to ship; exact SKU 0027075304857. [Source](https://carmarthencameras.com/products/pentax-d-fa-macro-100mm-hd-f2-8ed-aw-black) |
| Pentax O-RC1 waterproof remote | SCAN | £29.99 | New; exact code 39892, awaiting ETA / preorder. [Source](https://www.scan.co.uk/products/ricoh-pentax-o-rc1-remote-control) |
| Pentax O-RC1 waterproof remote | Clifton Cameras | £26.00 | New; exact MPN/EAN, awaiting stock, orders accepted, usually 5–7 days. [Source](https://www.cliftoncameras.co.uk/pentax-o-rc1-waterproof-remote-control) |
| Panasonic Lumix DC-FZ1000 II | Kamerastore | £709.00 | Certified used, in stock; zoom lever slow/unresponsive, viewfinder scratched; fault explicitly retained. [Source](https://kamerastore.com/en-gb/products/panasonic-lumix-dc-fz1000-ii-t150535) |
| Panasonic Lumix DMC-GM5 body only | Wex Photo Video | £929.00 | Used Excellent, in stock, approx. 4,000 shutter count, clean sensor, box/manual/battery/charger; USB cable not included. [Source](https://www.wexphotovideo.com/panasonic-lumix-dmc-gm5-body-only-used-3357606/) |

Batch 11 now has **22 active records: 8 UK New and 14 UK Used; all 22 are GBP**. Twelve additional records were inserted. Used prices remain reference-only. The Panasonic FZ1000 II zoom-unit fault is explicitly retained and must not be treated as a fully functional comparison. Nikon Df grip looseness and body condition are also noted.

Other leads remain RED VERIFY: Nikon S6900 marketplace leads are Japan sellers, including a faulty lens-error listing; Nikon Ai-S 800mm f/8 ED has no fully verified UK exact source; Nikon D60 body-only prices were available from retailer price comparison but no exact product page was opened in this follow-up; Nikon F2 Data back prices are JPY/EUR only; Nikon NIKONOS V Kamerastore item has untested waterproofing; Panasonic Leica 50-200mm Camix page has copied/contradictory product description and stock wording; Pentax Macro 100 Park price requires option/store selection and voucher not confirmed; Potensic Dreamer 1 catalogue identity versus Dreamer 4K still requires confirmation. These were not promoted as exact verified evidence.

No master product, tenant, customer, schema, valuation function, TEST or Stripe data was changed.


## 7. Further RED VERIFY review — 12 November 2026

Seven additional exact UK source observations were imported into LIVE and read back:

| Product | Source | Price | Verification |
|---|---|---:|---|
| Nikon COOLPIX P900 | Harrison Cameras | £420.00 | Used Very Good; one in stock; fully tested, 12-month warranty, free UK delivery; LCD has light scratches. [Source](https://harrisoncameras.co.uk/products/used-nikon-coolpix-p900-bridge-camera-used-40049503) |
| Nikon COOLPIX P900 | Wex Photo Video | £449.00 | Used Excellent; in stock; Wex item 3371097; box, manual, lens cap, EH-71P adapter, EN-EL23 battery and USB cable; 12-month warranty. [Source](https://www.wexphotovideo.com/nikon-coolpix-p900-digital-camera-used-3371097/) |
| Nikon F2AS Data | Grays of Westminster (via UsedLens UK) | £6,500.00 | As New; exact black F2AS Data with MF-10 Data Back. Bundle also includes MD-2/MB-1 motor drive and DS-12 EE aperture-control attachment; not a bare body/data-back price. [Source](https://usedlens.co.uk/product/nikon-f2as) |
| Panasonic Leica DG Vario-Elmarit 50-200mm f/2.8-4 | Park Cameras | £929.00 | Used Very Good; two units available; 12-month warranty. [Source](https://ufd3h5g456i7uds.parkcameras.com/used/lenses/used-micro-43rds-lenses/used-panasonic-50-200mm-f-2-8-4-micro-four-thirds-lens/) |
| Panasonic Leica DG Vario-Elmarit 50-200mm f/2.8-4 | MPB UK | £1,009.00 | Used; two available across £1,009–£1,059; individual grades/accessories vary. [Source](https://www.mpb.com/en-uk/category/used-photo-and-video-lenses/mirrorless-lenses/micro-four-thirds-fit-lenses) |
| Panasonic Lumix DMC-GM5 | MPB UK | £624.00 | Used Good; lowest of eight MPB listings (£624–£769); body comparison, accessory combinations vary. [Source](https://www.mpb.com/en-uk/product/panasonic-lumix-dmc-gm5) |
| Pentax smc PENTAX-FA 100mm f/2.8 Macro | eBay UK — Fivercam | £234.89 | Used; UK business seller, 99.6% positive, returns accepted; £49.99 UPS postage, recorded separately. [Source](https://www.ebay.co.uk/itm/257096058303) |

All seven records are UK Used and therefore reference-only for automatic valuation. Exact model distinctions are preserved: Nikon F2AS Data with MF-10 is not a standard F2AS body; Pentax older SMC FA 100mm is not D FA/HD D FA; Panasonic 50-200mm is the exact Leica DG Micro Four Thirds lens. The F2AS Data price is a bundled package with significant extras, not directly comparable to a bare standard camera package.

Batch 11 now has **29 active GBP records: 8 UK New and 21 UK Used**. All seven new rows were read back. Their observed_at values were normalized to the actual post-import verification time (not backdated or staggered); timestamps are shared because the observations were verified in the same import/read-back session.

Outstanding leads remain RED VERIFY where no exact UK offer could be verified: Nikon S6900 offers are Japan-based; Nikon Ai-S 800mm f/8 ED remains suffix/identity uncertain; Nikon F2 Data Grays bundle is not a bare package; Nikonos V waterproofing untested; Panasonic 50-200 Camix new-stock wording conflicts and Hong Kong seller offers exclude VAT; Panasonic FZ1000 II Kamerastore zoom lever fault must remain visible; Potensic Dreamer 1 vs Dreamer 4K identity still needs manufacturer/catalogue confirmation. No foreign currency or wrong model price was promoted.

No master product, tenant, customer, schema, valuation function, TEST or Stripe data was changed.


## 8. Nikon D60 — exact used-market sources verified and imported — 12 November 2026

The outstanding Nikon D60 body-only price leads were revisited using direct product pages. LIVE master: Nikon D60 / Nikon D60, ID d52bf262-7a5b-407c-8066-c548cfc06b24. No matching evidence or research-queue candidate existed before insertion.

Three exact UK used offers were imported into LIVE and read back:
- MPB SKU 4158743 — £52.00, Good; pop-up flash not working, LCD scratched but functional, shutter count 5,777; body cap, strap, battery door, eyecup, battery and charger; 12-month warranty. https://www.mpb.com/en-uk/product/nikon-d60/sku-4158743
- MPB SKU 4174829 — £67.00, Excellent; light dust under LCD and light LCD marks, shutter count 13,533; body cap, battery door, eyecup, battery and charger; 12-month warranty. https://www.mpb.com/en-uk/product/nikon-d60/sku-4174829
- London Camera Exchange item 259873 — £59.99, Good; Southampton Civic Centre, in store, next-working-day home delivery available; two batteries, charger, box, strap, guide book and instructions; six-month warranty. https://www.lcegroup.co.uk/Used/Nikon-D60-Body_500561.html

Evidence row IDs: 9e2df28b-340d-4e09-ad83-660ff34a6bb8; e3c42ef7-aa7a-45f1-a937-5fd13399b5e1; c788d584-728c-4e73-8f92-63499e232b24. All are active UK Used GBP reference records; the fault/condition/accessory differences are preserved. No valuation effect from UK Used.

Batch 11 now has 32 active GBP rows (8 UK New, 24 UK Used). Cumulative Batches 04–13: 240 GBP observations, 236 active (128 UK New, 108 UK Used), four inactive. No master product, tenant/customer, schema or valuation changes. TEST and Stripe untouched.


## 13 November 2026 — Nikon NIKKOR Z 50mm f/1.4 additional UK retailer observation

One further exact UK New GBP observation was imported and read back against the existing NIKKOR Z 50mm f/1.4 master beb389f1-c53e-4166-9cf6-2b07148df339:
- Wilkinson Cameras — £459.00, new, in stock and available in store; exact MPN JMA004DA / EAN 4960759915979, Nikon Z FX mount; box contents include lens, LC-62B cap, LF-N1 cap and HB-115 hood. Evidence ID 44ddeb36-b25c-4d1f-941f-5ca673c88f90. [Direct source](https://www.wilkinson.co.uk/nikon-nikkor-z-50mm-f-1-4-lens/)

The search snippet displayed a conflicting lower price; the opened direct product page displayed £459 and was used. Nikon UK's direct page still displays £449 in stock, so the existing Nikon UK £449 observation was not changed. Batch 11 now has 33 active GBP rows (9 UK New, 24 UK Used). UK Used remains reference-only. No master/schema/valuation changes; TEST and Stripe untouched.


## 13 November 2026 — Nikon COOLPIX S7000 used-market retailer follow-up

One additional exact Nikon COOLPIX S7000 used UK dealer listing was imported into LIVE against existing master f76e717f-4bba-422f-92b3-09aa6cb3d4bb:
- CameraWorld — £179.10, Used Excellent, one unique item in stock, SKU C-911912; supplied with battery, cable and strap; 12-month warranty and free UK delivery. Evidence ID 9d74d5d1-992b-4864-9b95-175bb9303081. [Direct source](https://www.cameraworld.co.uk/nikon-coolpix-s7000-compact-camera.html)

The search result exposed the direct product listing details; opening the URL returned a cache miss. This limitation is retained in the evidence notes for dashboard click-through recheck. Existing Kamerastore £158 certified-used observation remains active. UK Used is reference-only. Batch 11 now has 34 active GBP records (9 UK New, 25 UK Used), superseding the earlier 33-row count. No master/schema/valuation changes; TEST and Stripe untouched.
