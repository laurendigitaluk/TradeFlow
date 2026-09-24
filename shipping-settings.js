const SUPABASE_URL='https://twfbmjwwqzxdxvclxbun.supabase.co';
let key='',token='',tenantId='',catalog=[],connections=[];
const $=id=>document.getElementById(id);
const esc=v=>String(v??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]||c));
async function api(path,opts={}){
 const h=new Headers(opts.headers||{});h.set('apikey',key);h.set('Authorization','Bearer '+token);
 if(opts.body)h.set('Content-Type','application/json');
 const r=await fetch(SUPABASE_URL+path,{...opts,headers:h});const text=await r.text();let b;
 try{b=text?JSON.parse(text):null}catch{b=text}
 if(!r.ok)throw Error(b?.message||b?.msg||b?.error||text||'Request failed');return b;
}
async function testConnection(connectionId){
 const r=await fetch(SUPABASE_URL+'/functions/v1/shipping-provider-test',{
  method:'POST',
  headers:{'Content-Type':'application/json','Authorization':'Bearer '+token,'apikey':key},
  body:JSON.stringify({tenant_id:tenantId,connection_id:connectionId})
 });
 const text=await r.text();let b;try{b=text?JSON.parse(text):null}catch{b=text}
 if(!r.ok||b?.ok!==true)throw Error(b?.message||b?.error||text||'Parcel2Go connection test failed');
 return b;
}
function render(){
 const box=$('shipping-connections');const by=Object.fromEntries(connections.map(x=>[x.provider,x]));
 box.innerHTML='<div id="shipping-provider-list"></div>';
 const paint=()=>{
  const rows=catalog.filter(p=>p.provider_code==='parcel2go');
  $('shipping-provider-list').innerHTML=rows.map(p=>{
   const c=by[p.provider_code],s=c?.status||'not_connected';
   return '<article class="shipping-provider-card"><div class="shipping-provider-head"><div><strong>'+esc(p.provider_name)+'</strong><div class="small">'+esc(p.provider_type==='multi_carrier'?'Multi-carrier platform':'Direct courier / carrier')+'</div></div><span class="status-pill">'+esc(s==='connected'?'Connected':s==='pending'?'Setup saved — awaiting test':s==='error'?'Connection error':'Not connected')+'</span></div><p class="small">'+esc(p.description||'')+'</p><p class="small"><strong>Adapter:</strong> '+esc(p.adapter_status==='active'?'Active':'Not active yet')+'</p><div class="actions"><button type="button" data-provider="'+esc(p.provider_code)+'">Set up / connect</button>'+(p.setup_url||p.documentation_url||p.website_url?'<a href="'+esc(p.setup_url||p.documentation_url||p.website_url)+'" target="_blank" rel="noopener">Provider instructions</a>':'')+'</div></article>';
  }).join('');
  document.querySelectorAll('[data-provider]').forEach(b=>b.onclick=()=>openProvider(b.dataset.provider));
 };
 paint();
}
function openProvider(code){
 const p=catalog.find(x=>x.provider_code===code);if(!p)return;
 const box=$('shipping-provider-form'),fields=Array.isArray(p.required_fields)?p.required_fields:[];
 box.hidden=false;
 box.innerHTML='<div class="panel-subheading"><strong>'+esc(p.provider_name)+'</strong><span class="small">'+esc(p.setup_instructions||'Follow the provider setup instructions.')+'</span></div><div class="actions"><a href="'+esc(p.setup_url||p.documentation_url||p.website_url||'#')+'" target="_blank" rel="noopener">Open provider setup / documentation</a></div><div class="form-grid">'+fields.map(f=>'<label>'+esc(f.label)+(f.required?' *':'')+'<input id="shipping-field-'+esc(f.key)+'" type="'+(f.type==='password'?'password':'text')+'" '+(f.required?'required':'')+'></label>').join('')+'</div><div class="actions"><button id="shipping-save" type="button">Save and test connection</button></div><div id="shipping-provider-form-status" class="small"></div>';
 $('shipping-save').onclick=()=>saveProvider(p);
 box.scrollIntoView({behavior:'smooth',block:'start'});
}
async function saveProvider(p){
 const status=$('shipping-provider-form-status'),button=$('shipping-save');
 try{
  const credentials={};
  for(const f of(p.required_fields||[])){const e=$('shipping-field-'+f.key);if(f.required&&!e?.value.trim())throw Error('Enter '+f.label+'.');if(e?.value)credentials[f.key]=e.value.trim();}
  const clientId=credentials.api_client_id||'';
  const clientSecret=credentials.api_client_secret||'';
  if(p.provider_code==='parcel2go'){
   if(!clientId||!clientSecret)throw Error('Enter the Parcel2Go API Client ID and API Client Secret.');
   button.disabled=true;
   status.textContent='Saving the Parcel2Go credentials securely…';
   const result=await api('/rest/v1/rpc/subscriber_connect_shipping_provider',{method:'POST',body:JSON.stringify({
    p_tenant_id:tenantId,
    p_provider:'parcel2go',
    p_environment:$('shipping-environment').value,
    p_api_client_id:clientId,
    p_api_client_secret:clientSecret
   })});
   status.textContent='Credentials saved securely. Testing Parcel2Go authentication…';
   const test=await testConnection(result.connection_id);
   status.textContent='Connected successfully to Parcel2Go '+(test.environment==='live'?'Live':'Sandbox')+'. Authentication passed; no shipment was created.';
   await load();
  }else{
   const result=await api('/rest/v1/rpc/subscriber_save_shipping_provider_connection',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_provider:p.provider_code,p_environment:$('shipping-environment').value,p_credentials:credentials,p_config:{display_name:p.provider_name}})});
   status.textContent=result?.adapter_status==='active'?'Connection saved. Test it before using it.':'Connection saved securely. It will appear in label selection when its adapter is active and the connection has been tested.';
   await load();
  }
 }catch(e){status.textContent=e.message||String(e)}
 finally{button.disabled=false}
}
async function load(){
 try{
  const a=await window.tradeflowSubscriberAuthReady;key=a.key;token=a.session.access_token;tenantId=a.tenantId;
  $('business-name').textContent=a.tenants?.[tenantId]||'Shipping Settings';
  [catalog,connections]=await Promise.all([
   api('/rest/v1/shipping_provider_catalog?select=provider_code,provider_name,provider_type,connection_method,website_url,documentation_url,setup_url,description,setup_instructions,required_fields,adapter_status,sort_order,enabled&enabled=eq.true&order=sort_order'),
   api('/rest/v1/shipping_provider_connections?select=id,provider,status,display_name,connected_at,metadata&tenant_id=eq.'+encodeURIComponent(tenantId)+'&order=provider')
  ]);
  render();
 }catch(e){$('message').textContent=e.message||String(e)}
}
window.addEventListener('DOMContentLoaded',load);