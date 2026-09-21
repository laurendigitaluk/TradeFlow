const SUPABASE_URL='https://twfbmjwwqzxdxvclxbun.supabase.co';
let key,token,tenantId;
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
function renderBanner(url){
 const box=$('banner-preview'),remove=$('banner-remove');if(!box)return;
 box.innerHTML=url?'<img src="'+esc(url)+'" alt="Website banner">':'<span>No banner uploaded.</span>';
 if(remove)remove.disabled=!url;
}
async function uploadBanner(file){
 if(!file)return;
 if(file.size>5242880)throw Error('Image is larger than 5 MB.');
 if(!['image/png','image/jpeg','image/webp'].includes(file.type))throw Error('Use PNG, JPEG or WebP images only.');
 msg('Uploading website banner…');
 const safe=(file.name||'banner').toLowerCase().replace(/[^a-z0-9._-]+/g,'-');
 const path=tenantId+'/banner/'+Date.now()+'-'+safe;
 const r=await fetch(SUPABASE_URL+'/storage/v1/object/tradeflow-site-media/'+path.split('/').map(encodeURIComponent).join('/'),{method:'POST',headers:{apikey:key,Authorization:'Bearer '+token,'Content-Type':file.type,'x-upsert':'false'},body:file});
 const t=await r.text();if(!r.ok)throw Error(t||'Banner upload failed.');
 const url=SUPABASE_URL+'/storage/v1/object/public/tradeflow-site-media/'+path.split('/').map(encodeURIComponent).join('/');
 await api('/rest/v1/tenant_public_profiles?tenant_id=eq.'+encodeURIComponent(tenantId),{method:'PATCH',headers:{Prefer:'return=minimal'},body:JSON.stringify({banner_url:url})});
 try{await api('/rest/v1/media_assets',{method:'POST',headers:{Prefer:'return=minimal'},body:JSON.stringify({tenant_id:tenantId,storage_bucket:'tradeflow-site-media',storage_path:path,original_filename:file.name,mime_type:file.type,byte_size:file.size,status:'active',created_by:null,asset_kind:'site_banner',retention_policy:'permanent'})})}catch(e){console.warn('Banner metadata insert failed',e)}
 renderBanner(url);msg('Website banner saved.','success');
}
async function removeBanner(){
 if(!confirm('Remove the website banner from the customer-facing website?'))return;
 await api('/rest/v1/tenant_public_profiles?tenant_id=eq.'+encodeURIComponent(tenantId),{method:'PATCH',headers:{Prefer:'return=minimal'},body:JSON.stringify({banner_url:null})});
 renderBanner(null);msg('Website banner removed.','success');
}
function renderLogo(url){
 const box=$('logo-preview'),remove=$('logo-remove');if(!box)return;
 box.innerHTML=url?'<img src="'+esc(url)+'" alt="Business logo">':'<span>No logo uploaded.</span>';
 if(remove)remove.disabled=!url;
}
async function uploadLogo(file){
 if(!file)return;
 if(file.size>5242880)throw Error('Image is larger than 5 MB.');
 if(!['image/png','image/jpeg','image/webp'].includes(file.type))throw Error('Use PNG, JPEG or WebP images only.');
 msg('Uploading logo…');
 const safe=(file.name||'logo').toLowerCase().replace(/[^a-z0-9._-]+/g,'-');
 const path=tenantId+'/logo/'+Date.now()+'-'+safe;
 const r=await fetch(SUPABASE_URL+'/storage/v1/object/tradeflow-site-media/'+path.split('/').map(encodeURIComponent).join('/'),{method:'POST',headers:{apikey:key,Authorization:'Bearer '+token,'Content-Type':file.type,'x-upsert':'false'},body:file});
 const t=await r.text();if(!r.ok)throw Error(t||'Logo upload failed.');
 const url=SUPABASE_URL+'/storage/v1/object/public/tradeflow-site-media/'+path.split('/').map(encodeURIComponent).join('/');
 await api('/rest/v1/tenant_public_profiles?tenant_id=eq.'+encodeURIComponent(tenantId),{method:'PATCH',headers:{Prefer:'return=minimal'},body:JSON.stringify({logo_url:url})});
 try{await api('/rest/v1/media_assets',{method:'POST',headers:{Prefer:'return=minimal'},body:JSON.stringify({tenant_id:tenantId,storage_bucket:'tradeflow-site-media',storage_path:path,original_filename:file.name,mime_type:file.type,byte_size:file.size,status:'active',created_by:null,asset_kind:'site_logo',retention_policy:'permanent'})})}catch(e){console.warn('Logo metadata insert failed',e)}
 renderLogo(url);msg('Business logo saved.','success');
}
async function removeLogo(){
 if(!confirm('Remove the business logo from the customer-facing website?'))return;
 await api('/rest/v1/tenant_public_profiles?tenant_id=eq.'+encodeURIComponent(tenantId),{method:'PATCH',headers:{Prefer:'return=minimal'},body:JSON.stringify({logo_url:null})});
 renderLogo(null);msg('Business logo removed.','success');
}
async function load(){
 try{
  const a=await window.tradeflowSubscriberAuthReady;key=a.key;token=a.session.access_token;tenantId=a.tenantId;
  $('business-name').textContent=a.tenants?.[tenantId]||'Business Settings';
  $('account-summary').textContent=(a.user?.email||'')+' · '+(a.role||'');
  const profiles=await api('/rest/v1/tenant_public_profiles?select=tenant_id,business_name,public_email,public_phone,address_line1,address_line2,city,county,postcode,country_code,description,logo_url,banner_url,show_email,show_phone,show_address&tenant_id=eq.'+encodeURIComponent(tenantId));
  const p=profiles?.[0]||{};
  const tenants=await api('/rest/v1/tenants?select=id,name&id=eq.'+encodeURIComponent(tenantId));
  setValue('business-name-input',tenants?.[0]?.name||a.tenants?.[tenantId]||'');
  renderLogo(p.logo_url||null);renderBanner(p.banner_url||null);
  setValue('public-email',p.public_email);const emailStatus=await api('/rest/v1/rpc/subscriber_get_email_status',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId})});setValue('business-email',emailStatus?.business_email||p.public_email||'');renderEmailStatus(emailStatus);setValue('public-phone',p.public_phone);setValue('country-code',p.country_code||'GB');
  setValue('address-line1',p.address_line1);setValue('address-line2',p.address_line2);setValue('city',p.city);setValue('county',p.county);setValue('postcode',p.postcode);setValue('description',p.description);
  setChecked('show-email',p.show_email);setChecked('show-phone',p.show_phone);setChecked('show-address',p.show_address);
  const rows=await api('/rest/v1/tenant_payment_methods?select=id,method_code,display_name,enabled,instructions,sort_order&tenant_id=eq.'+encodeURIComponent(tenantId)+'&order=sort_order,display_name');
  $('methods').innerHTML=rows?.length?rows.map(x=>'<div style="border-top:1px solid #dfe4e8;padding:12px 0;display:flex;justify-content:space-between;gap:15px;align-items:flex-start"><div><strong>'+esc(x.display_name)+'</strong><div class="small">'+esc(x.instructions||'No customer instructions.')+'</div></div><span class="status-pill">'+(x.enabled?'Enabled':'Disabled')+'</span></div>').join(''):'<div class="empty">No payment methods configured yet.</div>';
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
$('method-form').onsubmit=async e=>{
 e.preventDefault();
 try{
  const code=$('method-code').value,name=$('method-name').value.trim();if(!name)throw Error('Display name is required.');
  await api('/rest/v1/tenant_payment_methods?on_conflict=tenant_id,method_code',{method:'POST',headers:{Prefer:'resolution=merge-duplicates,return=minimal'},body:JSON.stringify({tenant_id:tenantId,method_code:code,display_name:name,enabled:true,instructions:$('method-instructions').value.trim()||null})});
  msg('Payment method saved.','success');await load();
 }catch(e){msg(e.message||String(e),'error')}
};
$('sign-out').onclick=()=>window.tradeflowSubscriberSignOut();
if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',load,{once:true});else load();
$('logo-upload').onclick=()=>{const i=$('logo-file-input');i.value='';i.click()};
$('logo-file-input').onchange=e=>uploadLogo(e.target.files?.[0]).catch(err=>msg(err.message||String(err),'error'));
$('logo-remove').onclick=()=>removeLogo().catch(err=>msg(err.message||String(err),'error'));

$('banner-upload').onclick=()=>{const i=$('banner-file-input');i.value='';i.click()};
$('banner-file-input').onchange=e=>uploadBanner(e.target.files?.[0]).catch(err=>msg(err.message||String(err),'error'));
$('banner-remove').onclick=()=>removeBanner().catch(err=>msg(err.message||String(err),'error'));
