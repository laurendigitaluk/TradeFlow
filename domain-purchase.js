const SUPABASE_URL='https://twfbmjwwqzxdxvclxbun.supabase.co';const $=id=>document.getElementById(id);
const esc=v=>String(v??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]||c));
const TLDs=['co.uk','com','uk'];
async function check(tld,domain,auth){
  const r=await fetch(SUPABASE_URL+'/functions/v1/porkbun-domain-availability',{method:'POST',headers:{apikey:auth.key,Authorization:'Bearer '+auth.session.access_token,'Content-Type':'application/json'},body:JSON.stringify({domain})});
  const text=await r.text();let body=null;try{body=text?JSON.parse(text):null}catch{body=text}
  if(!r.ok)throw Error(body?.error||body?.message||text||('HTTP '+r.status));
  return body;
}
function render(results){
  $('results').innerHTML=results.map(r=>{
    const available=r.available===true||r.status==='available';
    const unavailable=r.available===false||r.status==='unavailable';
    const status=available?'Available':unavailable?'Unavailable':r.status==='error'?'Provider request failed':'Availability check unavailable';
    const cls=available?'status-pill':unavailable?'status-pill muted':r.status==='error'?'status-pill warning':'status-pill warning';
    const price=available&&r.price!=null?'<p class="small"><strong>Registration price:</strong> '+esc(String(r.currency||'USD'))+' '+esc(Number(r.price).toFixed(2))+'</p>':'';
    const action=available?'<button type="button" class="domain-select-button" data-domain="'+esc(r.domain)+'">Choose this domain</button>':'';
    const detail=r.status==='unknown'&&!('available' in r)?'The registry did not return a definitive answer. Try the search again later.':r.status==='error'?esc(r.error||'The provider request failed without a message.'):'';
    return '<div class="panel" style="margin-top:10px;padding:15px"><div style="display:flex;justify-content:space-between;gap:15px;align-items:center"><strong>'+esc(r.domain)+'</strong><span class="'+cls+'">'+status+'</span></div>'+price+(detail?'<p class="small">'+detail+'</p>':'')+(action?'<div class="actions" style="margin-top:12px">'+action+'</div>':'')+'</div>';
  }).join('');
  document.querySelectorAll('.domain-select-button').forEach(button=>{
    button.onclick=()=>{
      const domain=button.dataset.domain||'';
      $('message').textContent='Selected '+domain+'. The purchase step is not enabled yet.';
    };
  });
}
(async()=>{
 try{
  const auth=await window.tradeflowSubscriberAuthReady;
  $('business-name').textContent=auth.tenants?.[auth.tenantId]||'Buy a domain';
  $('sign-out').onclick=()=>window.tradeflowSubscriberSignOut?.();
  $('domain-search-form').onsubmit=async e=>{
   e.preventDefault();
   const domain=$('domain-name').value.trim().toLowerCase().replace(/^https?:\/\//,'').split('/')[0].replace(/\.$/,'');
   $('message').textContent='Checking availability…';$('results').innerHTML='';
   try{
    const results=[];
    for(const tld of TLDs){
      try{results.push(await check(tld,domain+'.'+tld,auth));}
      catch(err){results.push({domain:domain+'.'+tld,status:'error',error:err.message});}
    }
    render(results);$('message').textContent='Availability check complete.';
   }catch(err){$('message').textContent=err.message||String(err);}
  };
 }catch(err){$('message').textContent=err.message||String(err);}
})();