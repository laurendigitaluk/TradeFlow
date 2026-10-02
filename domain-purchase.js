const SUPABASE_URL='https://twfbmjwwqzxdxvclxbun.supabase.co';const $=id=>document.getElementById(id);
const esc=v=>String(v??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]||c));
const TLDs=['co.uk','com','uk'];

function normaliseSearch(value){
  return String(value||'').trim().toLowerCase()
    .replace(/^https?:\/\//,'').split('/')[0].replace(/\.$/,'')
    .replace(/\.[a-z]{2,63}$/,'')
    .replace(/[^a-z0-9]+/g,' ')
    .trim();
}

function buildSearchDomains(raw){
  const cleaned=normaliseSearch(raw);
  const words=cleaned.split(/\s+/).filter(Boolean);
  if(!words.length) return {exact:[],suggestions:[]};
  const compact=words.join('');
  const hyphenated=words.join('-');
  const first=words[0];
  const last=words[words.length-1];
  const bases=[compact,hyphenated,compact+'uk',hyphenated+'-uk',first+'dash',first+'dashuk',last,last+'uk'];
  const domains=[];
  for(const base of bases){
    for(const tld of TLDs){
      const domain=base+'.'+tld;
      if(!domains.includes(domain)) domains.push(domain);
    }
  }
  return {
    exact:TLDs.map(tld=>compact+'.'+tld),
    suggestions:domains.filter(domain=>!TLDs.some(tld=>domain===compact+'.'+tld))
  };
}

async function checkMany(domains,auth){
  const r=await fetch(SUPABASE_URL+'/functions/v1/porkbun-domain-availability',{
    method:'POST',
    headers:{apikey:auth.key,Authorization:'Bearer '+auth.session.access_token,'Content-Type':'application/json'},
    body:JSON.stringify({domains})
  });
  const text=await r.text();let body=null;try{body=text?JSON.parse(text):null}catch{body=text}
  if(!r.ok)throw Error(body?.error||body?.message||text||('HTTP '+r.status));
  if(body?.status!=='SUCCESS')throw Error(body?.error||'Domain availability check failed.');
  return Array.isArray(body.results)?body.results:[];
}

function card(r,similar=false){
  const available=r.available===true||r.status==='available';
  const unavailable=r.available===false||r.status==='unavailable';
  const status=available?'Available':unavailable?'Unavailable':r.status==='invalid'?'Not checkable':r.status==='error'?'Provider request failed':'Availability unavailable';
  const cls=available?'status-pill':unavailable?'status-pill muted':'status-pill warning';
  const price=available&&r.price!=null?'<p class="small"><strong>Registration price:</strong> '+esc(String(r.currency||'USD'))+' '+esc(Number(r.price).toFixed(2))+'</p>':'';
  const action=available?'<button type="button" class="domain-select-button" data-domain="'+esc(r.domain)+'">Choose this domain</button>':'';
  return '<div class="panel" style="margin-top:10px;padding:15px"><div style="display:flex;justify-content:space-between;gap:15px;align-items:center"><strong>'+esc(r.domain)+'</strong><span class="'+cls+'">'+status+'</span></div>'+price+(action?'<div class="actions" style="margin-top:12px">'+action+'</div>':'')+'</div>';
}

function wireSelection(){
  document.querySelectorAll('.domain-select-button').forEach(button=>{
    button.onclick=()=>{
      const domain=button.dataset.domain||'';
      $('message').textContent='Selected '+domain+'. The purchase step is not enabled yet.';
    };
  });
}

function render(exactResults,suggestionResults){
  const exactAvailable=exactResults.some(r=>r.available===true||r.status==='available');
  let html=exactResults.map(r=>card(r)).join('');
  if(!exactAvailable){
    const availableSuggestions=suggestionResults.filter(r=>r.available===true||r.status==='available');
    html+='<div style="margin-top:22px"><div class="eyebrow">Similar domain suggestions</div><h3>Try one of these available names</h3>';
    html+=availableSuggestions.length
      ? availableSuggestions.map(r=>card(r,true)).join('')
      : '<p class="small">No similar available names were found for this search.</p>';
    html+='</div>';
  }
  $('results').innerHTML=html;
  wireSelection();
}

(async()=>{
 try{
  const auth=await window.tradeflowSubscriberAuthReady;
  $('business-name').textContent=auth.tenants?.[auth.tenantId]||'Buy a domain';
  $('sign-out').onclick=()=>window.tradeflowSubscriberSignOut?.();
  $('domain-search-form').onsubmit=async e=>{
   e.preventDefault();
   const search=buildSearchDomains($('domain-name').value);
   if(!search.exact.length){$('message').textContent='Enter a domain or business name to search.';return;}
   $('message').textContent='Checking availability…';$('results').innerHTML='';
   try{
    const results=await checkMany([...search.exact,...search.suggestions],auth);
    const byDomain=new Map(results.map(r=>[r.domain,r]));
    const exactResults=search.exact.map(domain=>byDomain.get(domain)||{domain,status:'unknown',available:null});
    const suggestionResults=search.suggestions.map(domain=>byDomain.get(domain)||{domain,status:'unknown',available:null});
    render(exactResults,suggestionResults);
    $('message').textContent='Availability check complete.';
   }catch(err){$('message').textContent=err.message||String(err);}
  };
 }catch(err){$('message').textContent=err.message||String(err);}
})();