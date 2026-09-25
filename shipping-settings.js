const SUPABASE_URL='https://twfbmjwwqzxdxvclxbun.supabase.co';
let key='',token='',tenantId='',catalog=[],selected=[];
const $=id=>document.getElementById(id);
const esc=v=>String(v??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]||c));
async function api(path,o={}){const h=new Headers(o.headers||{});h.set('apikey',key);h.set('Authorization','Bearer '+token);if(o.body)h.set('Content-Type','application/json');const r=await fetch(SUPABASE_URL+path,{...o,headers:h});const t=await r.text();let b;try{b=t?JSON.parse(t):null}catch{b=t}if(!r.ok)throw Error(b?.message||b?.msg||b?.error||t||'Request failed');return b}
function render(){
 const box=$('shipping-service-list');
 box.innerHTML='<div class="shipping-service-grid">'+catalog.map(x=>{
   const s=selected.find(v=>v.service_code===x.service_code);
   return '<label class="shipping-service-option"><input type="checkbox" data-service-code="'+esc(x.service_code)+'" '+(s?'checked':'')+'><span class="service-body"><span class="service-head"><strong>'+esc(x.service_name)+'</strong><a class="service-link" href="'+esc(x.service_url)+'" target="_blank" rel="noopener">Open website</a></span><span class="small">'+esc(x.description||'')+'</span></span></label>';
 }).join('')+'</div>';
}
async function load(){
 try{
  const a=await window.tradeflowSubscriberAuthReady;key=a.key;token=a.session.access_token;tenantId=a.tenantId;
  $('business-name').textContent=a.tenants?.[tenantId]||'Shipping Settings';
  catalog=await api('/rest/v1/shipping_service_catalog?select=service_code,service_name,service_url,service_type,description,sort_order&active=eq.true&order=sort_order,service_name');
  selected=await api('/rest/v1/tenant_shipping_services?select=service_code,service_name,service_url,enabled,sort_order&tenant_id=eq.'+encodeURIComponent(tenantId)+'&enabled=eq.true&order=sort_order,service_name');
  render();
 }catch(e){$('message').textContent=e.message||String(e);$('message').className='small error'}
}
$('save-shipping-services').onclick=async()=>{
 const status=$('shipping-save-status'),button=$('save-shipping-services');
 try{
  button.disabled=true;status.textContent='Saving selected shipping services…';
  const items=[...document.querySelectorAll('[data-service-code]:checked')].map((e,i)=>{
    const c=catalog.find(x=>x.service_code===e.dataset.serviceCode);
    return {service_code:e.dataset.serviceCode,service_url:c?.service_url||'',enabled:true,sort_order:i+1};
  });
  await api('/rest/v1/rpc/subscriber_save_shipping_services',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_services:items})});
  status.textContent=items.length?items.length+' shipping service'+(items.length===1?'':'s')+' saved.':'No shipping services selected.';
  selected=items.map(x=>Object.assign({},x,{service_name:catalog.find(c=>c.service_code===x.service_code)?.service_name||x.service_code}));
 }catch(e){status.textContent=e.message||String(e)}
 finally{button.disabled=false}
};
$('add-custom-service').onclick=async()=>{
 const status=$('custom-service-status'),name=$('custom-service-name').value.trim(),url=$('custom-service-url').value.trim();
 try{
  if(!name)throw Error('Enter a service name.');
  if(!/^https:\/\//i.test(url))throw Error('Enter a valid HTTPS shipping link.');
  const code='custom_'+crypto.randomUUID();
  const items=[...selected.map((x,i)=>({service_code:x.service_code,service_url:x.service_url,enabled:true,sort_order:i+1})),{service_code:code,service_name:name,service_url:url,enabled:true,sort_order:selected.length+1}];
  await api('/rest/v1/shipping_service_catalog',{method:'POST',headers:{Prefer:'return=minimal'},body:JSON.stringify({service_code:code,service_name:name,service_url:url,service_type:'specialist',description:'Custom shipping provider',sort_order:9000+selected.length,active:true})});
  await api('/rest/v1/rpc/subscriber_save_shipping_services',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_services:items})});
  status.textContent='Custom shipping service added and selected.';
  $('custom-service-name').value='';$('custom-service-url').value='';
  await load();
 }catch(e){status.textContent=e.message||String(e)}
};
$('sign-out').onclick=()=>window.tradeflowSubscriberSignOut();
if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',load,{once:true});else load();