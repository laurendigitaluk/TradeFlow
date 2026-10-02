export type KnowledgeEntry = { id:string; title:string; topics:string[]; content:string };

export const APPROVED_KNOWLEDGE: KnowledgeEntry[] = [
 {id:"website-builder",title:"Website Builder",topics:["website","builder","template","logo","branding","publish","preview"],content:"Website Builder controls templates, colours, backgrounds, typography, page text, images and optional pages. Save Draft stores changes, Preview checks the draft, and Publish Website makes the saved revision live."},
 {id:"buying",title:"Buying Catalogue",topics:["buying","catalogue","product","category","manufacturer","model"],content:"What We Buy is supplied from the subscriber's active Buying Catalogue. Products are added from the Master Catalogue. The Buying Catalogue is authoritative for products the business buys."},
 {id:"selling",title:"Inventory and Selling",topics:["selling","inventory","listing","retail","stock"],content:"What We Sell is supplied from published Selling listings. Inventory is the operational stock record after purchase completion. An inventory asset must not be repeatedly sent to Sales to create duplicates."},
 {id:"workflow",title:"Buying workflow",topics:["valuation","offer","shipping","receipt","inspection","payment"],content:"The acquisition journey is Buying, Valuation, Offer, Customer response, Shipping/receipt, Inspection, Final offer, Payment, Inventory, then Selling. Accepting an offer does not itself make the item inventory."},
 {id:"shipping",title:"Manual shipping",topics:["shipping","label","tracking","carrier","courier","qr"],content:"TradeFlow shipping is manual. Subscribers configure preferred services under Settings -> Shipping Settings and record the hand-off in TradeFlow. The customer pays their own shipping. Parcel2Go API and automated shipping-payment flows are retired."},
 {id:"domains",title:"Domains",topics:["domain","dns","custom domain","registrar"],content:"TradeFlow supports subscriber custom domains. The current camerashack.co.uk domain is a Porkbun sandbox test registration and does not prove real public DNS or Cloudflare routing."},
 {id:"assistant",title:"TradeFlow assistant",topics:["ai","assistant","chatbot","gemma","provider"],content:"The TradeFlow assistant is initially read-only and uses approved TradeFlow knowledge plus minimum authenticated tenant information. It does not have unrestricted SQL access. Personal desktop Gemma for Quote System research is separate from TradeFlow."},
 {id:"research",title:"Product Research",topics:["research","evidence","price","valuation"],content:"Product Research researches a specific product, presents evidence and sources, and requires subscriber approval before evidence is saved or used by buying-price calculations. AI must not silently change a buying price."},
 {id:"security",title:"Tenant security",topics:["security","privacy","tenant","customer","permission"],content:"tenant_id is the primary TradeFlow security boundary. Subscriber roles are owner, admin and staff. The assistant must never expose another tenant's customers, orders, inventory, valuations, payments, domains or business information."},
 {id:"settings",title:"Subscriber settings",topics:["settings","account","business","configuration","services"],content:"Subscriber settings control the business workspace and its configured services. Shipping services are managed under Settings -> Shipping Settings. Account and business settings must remain tenant-scoped."},
 {id:"offers-payment",title:"Offers and payment",topics:["offer","final","payment","bank","paid","valuation"],content:"TradeFlow keeps valuation, offer, customer response, inspection and payment as separate stages. A final offer is received before payment is processed. Payment confirmation must not be treated as inventory creation until the workflow has completed the required receipt and inspection stages."},
 {id:"customer-portal",title:"Customer portal",topics:["customer","portal","order","tracking","bank","details"],content:"Customer-facing information is limited to that customer's own tenant-scoped requests, orders and workflow status. Customer shipping/tracking information is provided through the existing order workflow. Customer payment and bank details must not be exposed to another customer or tenant."},
 {id:"selling-workflow",title:"Selling workflow",topics:["sell","sales","listing","channel","ebay","amazon","website"],content:"After purchase and completion of Inventory, the physical inventory asset is the master stock record. Sending an asset to Sales must not create duplicate listings. Sales channels can include the TradeFlow website and configured external channels; the inventory asset remains the master record."},
 {id:"public-website",title:"Published subscriber website",topics:["public","website","domain","publish","dns","storefront"],content:"Publishing a subscriber website creates the published revision and maps active subscriber custom hostnames through the published-site routing model. A sandbox registrar domain cannot prove real public DNS or Cloudflare routing; genuine-domain testing is a separate launch stage."}
];

export function retrieveKnowledge(question:string,maxEntries=4):KnowledgeEntry[] {
 const normalized=question.toLowerCase();
 const terms=normalized.split(/[^a-z0-9]+/).filter(Boolean);
 return APPROVED_KNOWLEDGE.map(entry=>{
   let score=0;
   for(const topic of entry.topics){
     if(normalized.includes(topic)) score+=4;
     for(const word of topic.split(/[^a-z0-9]+/).filter(Boolean)) if(terms.includes(word)) score++;
   }
   return {entry,score};
 }).filter(x=>x.score>0).sort((a,b)=>b.score-a.score).slice(0,maxEntries).map(x=>x.entry);
}
