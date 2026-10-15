const SUPABASE_URL='https://gxsrajtqzdjvmceqcpgv.supabase.co';
let key,token,tenantId,businessPostcode='';
const $=id=>document.getElementById(id);
const esc=v=>String(v??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]||c));
function msg(t,type=''){const e=$('message');e.textContent=t;e.className='small '+type}
async function api(path,o={}){const h=new Headers(o.headers||{});h.set('apikey',key);h.set('Authorization','Bearer '+token);if(o.body)h.set('Content-Type','application/json');const r=await fetch(SUPABASE_URL+path,{...o,headers:h});const t=await r.text();let b;try{b=t?JSON.parse(t):null}catch{b=t}if(!r.ok)throw Error(b?.message||b?.msg||b?.error||t||'Request failed');return b}
function setValue(id,v){const e=$(id);if(e)e.value=v??''}
function setChecked(id,v){const e=$(id);if(e)e.checked=v!==false}
function renderEmailStatus(s){
 const pill=$('email-status-pill'),box=$('email-status');if(!pill||!box)return;
 if(!s.business_email){pill.textContent='Not set';box.textContent='Enter your business email once. TradeFlow will handle the rest.';return;}
 if(s.ready){pill.textContent='Ready';box.textContent='Email is ready. Customer emails will use this address for replies, and important TradeFlow notifications will be sent here.';return;}
 if(s.platform_email_status==='not_configured'){pill.textContent='Waiting';box.textContent='Your business email is saved. TradeFlow is still waiting for the platform sending email to be configured by the TradeFlow owner. You do not need to do anything else.';return;}
 pill.textContent='Setting up';box.textContent='Your business email is saved. TradeFlow is completing the platform email setup. You do not need to configure anything else here.';
}





let stripeMethodRows=[];
function renderStripeMethods(){
 const host=$('stripe-methods');if(!host)return;
 host.innerHTML=stripeMethodRows.length?stripeMethodRows.map(x=>{
  const required=x.method_code==='card';
  const label=x.method_code==='card'?'Cards':x.method_code==='link'?'Link':x.method_code==='klarna'?'Klarna':x.method_code==='amazon_pay'?'Amazon Pay':x.display_name;
  return '<div class="stripe-method-row"><div><strong>'+esc(label)+'</strong><div class="small">'+(required?'Required base payment method.':'Available only where enabled in Stripe and eligible for the customer and transaction.')+'</div></div><label class="stripe-toggle"><input type="checkbox" class="stripe-method-toggle" data-method-id="'+esc(x.id)+'" '+(x.enabled?'checked':'')+(required?' disabled':'')+'><span>'+(x.enabled?'Enabled':'Disabled')+'</span></label></div>';
 }).join(''):'<div class="empty">Payment-method settings are not available yet.</div>';
 host.querySelectorAll('.stripe-method-toggle').forEach(el=>el.addEventListener('change',async()=>{
  const id=el.dataset.methodId,enabled=el.checked;el.disabled=true;
  try{await api('/rest/v1/tenant_payment_methods?id=eq.'+encodeURIComponent(id)+'&tenant_id=eq.'+encodeURIComponent(tenantId),{method:'PATCH',headers:{Prefer:'return=minimal'},body:JSON.stringify({enabled})});const row=stripeMethodRows.find(x=>x.id===id);if(row)row.enabled=enabled;el.nextElementSibling.textContent=enabled?'Enabled':'Disabled';msg('Payment method setting saved.','success');}
  catch(e){el.checked=!enabled;msg(e.message||String(e),'error');}
  finally{el.disabled=false}
 }));
}
async function loadStripeConnectStatus(){
 const status=$('stripe-connect-status'),message=$('stripe-connect-message'),button=$('stripe-connect-button');
 if(!status||!message||!button||!tenantId)return;
 status.textContent='Checking connection…';message.textContent='';
 try{
  const result=await api('/functions/v1/stripe-connect-onboarding',{method:'POST',body:JSON.stringify({tenant_id:tenantId,action:'status'})});
  if(result.connected){
   status.textContent='Connected';message.textContent='Stripe is connected. Charges and payouts are enabled.';
   button.textContent='Connected';button.disabled=true;
  }else{
   status.textContent=result.status==='onboarding'?'Setup incomplete':'Not connected';
   message.textContent=result.message||'Connect Stripe to start receiving customer payments.';
   button.textContent=result.status==='onboarding'?'Continue Stripe setup':'Connect Stripe';button.disabled=false;
  }
 }catch(e){status.textContent='Unable to verify';message.textContent=e.message||'Could not check Stripe status. Please try again.';button.disabled=false}
}
async function startStripeConnect(){
 const button=$('stripe-connect-button'),message=$('stripe-connect-message');
 if(!tenantId){message.textContent='Your business workspace is not ready. Please sign in again.';return}
 button.disabled=true;message.textContent='Opening secure Stripe setup…';
 try{
  const result=await api('/functions/v1/stripe-connect-onboarding',{method:'POST',body:JSON.stringify({tenant_id:tenantId,action:'connect'})});
  if(!result.url)throw Error(result.error||'Stripe did not return a secure setup link.');
  window.location.assign(result.url);
 }catch(e){message.textContent=e.message||'Unable to start Stripe setup.';button.disabled=false}
}
async function load(){
 try{
  const a=await window.tradeflowSubscriberAuthReady;key=a.key;token=a.session.access_token;tenantId=a.tenantId;
  $('business-name').textContent=a.tenants?.[tenantId]||'Business Settings';
  $('account-summary').textContent=(a.user?.email||'')+' · '+(a.role||'');
  const profiles=await api('/rest/v1/tenant_public_profiles?select=tenant_id,business_name,public_email,public_phone,address_line1,address_line2,city,county,postcode,country_code,description,show_email,show_phone,show_address&tenant_id=eq.'+encodeURIComponent(tenantId));
  const p=profiles?.[0]||{};
  const tenants=await api('/rest/v1/tenants?select=id,name&id=eq.'+encodeURIComponent(tenantId));
  setValue('business-name-input',tenants?.[0]?.name||a.tenants?.[tenantId]||'');
  
  setValue('public-email',p.public_email);const emailStatus=await api('/rest/v1/rpc/subscriber_get_email_status',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId})});setValue('business-email',emailStatus?.business_email||p.public_email||'');renderEmailStatus(emailStatus);setValue('public-phone',p.public_phone);setValue('country-code',p.country_code||'GB');
  setValue('address-line1',p.address_line1);setValue('address-line2',p.address_line2);setValue('city',p.city);setValue('county',p.county);setValue('postcode',p.postcode);businessPostcode=p.postcode||'';setValue('description',p.description);
  setChecked('show-email',p.show_email);setChecked('show-phone',p.show_phone);setChecked('show-address',p.show_address);
  $('stripe-connect-button')?.addEventListener('click',startStripeConnect);
  $('stripe-refresh-status')?.addEventListener('click',loadStripeConnectStatus);
  const stripeReturn=new URLSearchParams(location.search).get('stripe_connect');
  if(stripeReturn){history.replaceState({},'',location.pathname);}
  await loadStripeConnectStatus();
  const defaults=[
   {method_code:'card',display_name:'Credit or debit card',enabled:true,sort_order:10},
   {method_code:'link',display_name:'Link',enabled:true,sort_order:20},
   {method_code:'klarna',display_name:'Klarna',enabled:true,sort_order:30},
   {method_code:'amazon_pay',display_name:'Amazon Pay',enabled:true,sort_order:40}
  ];
  await api('/rest/v1/tenant_payment_methods?on_conflict=tenant_id,method_code',{
   method:'POST',
   headers:{Prefer:'resolution=ignore-duplicates,return=minimal'},
   body:JSON.stringify(defaults.map(x=>({...x,tenant_id:tenantId})))
  });
  stripeMethodRows=await api('/rest/v1/tenant_payment_methods?select=id,method_code,display_name,enabled,sort_order&tenant_id=eq.'+encodeURIComponent(tenantId)+'&method_code=in.(card,link,klarna,amazon_pay)&order=sort_order');
  renderStripeMethods();
 }catch(e){msg(e.message||String(e),'error')}
}
$('email-form').onsubmit=async e=>{
 e.preventDefault();
 try{
  const email=$('business-email').value.trim().toLowerCase();
  if(!email)throw Error('Please enter your business email address.');
  const result=await api('/rest/v1/rpc/subscriber_save_business_email',{method:'POST',headers:{Prefer:'return=representation'},body:JSON.stringify({p_tenant_id:tenantId,p_email:email})});
  await api('/rest/v1/tenant_public_profiles?tenant_id=eq.'+encodeURIComponent(tenantId),{method:'PATCH',headers:{Prefer:'return=minimal'},body:JSON.stringify({public_email:email,show_email:true})});
  renderEmailStatus({business_email:email,business_email_enabled:true,platform_email_status:'pending',ready:false});
  msg('Business email saved. TradeFlow will use this address for your business email.','success');
 }catch(e){msg(e.message||String(e),'error')}
};
$('profile-form').onsubmit=async e=>{
 e.preventDefault();
 try{
  const name=$('business-name-input').value.trim();
  if(!name)throw Error('Business name is required.');
  await api('/rest/v1/tenants?id=eq.'+encodeURIComponent(tenantId),{method:'PATCH',headers:{Prefer:'return=minimal'},body:JSON.stringify({name})});
  await api('/rest/v1/tenant_public_profiles?tenant_id=eq.'+encodeURIComponent(tenantId),{method:'PATCH',headers:{Prefer:'return=minimal'},body:JSON.stringify({
   business_name:name,public_email:$('public-email').value.trim()||null,public_phone:$('public-phone').value.trim()||null,
   address_line1:$('address-line1').value.trim()||null,address_line2:$('address-line2').value.trim()||null,
   city:$('city').value.trim()||null,county:$('county').value.trim()||null,postcode:$('postcode').value.trim()||null,
   country_code:$('country-code').value.trim().toUpperCase()||'GB',description:$('description').value.trim()||null,
   show_email:$('show-email').checked,show_phone:$('show-phone').checked,show_address:$('show-address').checked
  })});
  msg('Business details saved.','success');$('business-name').textContent=name;
 }catch(e){msg(e.message||String(e),'error')}
};
$('sign-out').onclick=()=>window.tradeflowSubscriberSignOut();
if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',load,{once:true});else load();

