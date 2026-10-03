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





const PAYMENT_PROVIDERS=[
 {code:'stripe',name:'Stripe',description:'Online checkout, cards, wallets and payment links.',signup:'https://dashboard.stripe.com/register',guide:'https://stripe.com/gb/payments/payment-links',ready:['Business details and identity verification','Business bank account for payouts','Stripe account email','Stripe account ID if shown','Optional Stripe Payment Link for simple link-based payments'],steps:['Create your Stripe account.','Complete Stripe business verification.','Add your business bank account for payouts.','In Stripe Dashboard, confirm that payments are enabled.','Return to TradeFlow and record the non-secret account details below.']},
 {code:'paypal',name:'PayPal Business',description:'PayPal, cards, Pay Later and online checkout.',signup:'https://www.paypal.com/uk/business/open-business-account',guide:'https://www.paypal.com/uk/webapps/mpp/business/accept-payments',ready:['Business name and address','Date of birth and home address','Business bank sort code and account number','PayPal Business account email','Optional PayPal payment link if you use one'],steps:['Open a PayPal Business account.','Confirm your business information.','Link your business bank account.','Complete any PayPal verification requested.','Return to TradeFlow and record the non-secret account details below.']},
 {code:'sumup',name:'SumUp',description:'Simple online payments and reusable payment links.',signup:'https://www.sumup.com/en-gb/',guide:'https://www.sumup.com/en-gb/payment-links/',ready:['Email address and mobile number','Business type and category','Business address and postcode','Identity document and selfie','Website or social profile if requested','SumUp account email','Optional SumUp Payment Link'],steps:['Create your SumUp profile.','Complete identity and business verification.','Enter your business address, including postcode.','Open Payment Links in SumUp and create a payment link if you want link-based checkout.','Return to TradeFlow and record the non-secret details below.']},
 {code:'square',name:'Square',description:'Online payments and simple Payment Links.',signup:'https://squareup.com/signup',guide:'https://squareup.com/help/gb/en/article/6692-get-started-with-square-checkout-links',ready:['Email and password','Business name, type and category','Estimated annual revenue','Business address and phone number','Identity verification','Square account email','Optional Square Payment Link'],steps:['Create your Square account and select United Kingdom.','Enter your business information.','Complete Square payment activation and identity verification.','Create a Payment Link in Square Dashboard if you want one.','Return to TradeFlow and record the non-secret details below.']},
 {code:'mollie',name:'Mollie',description:'Online checkout, payment links and multiple payment methods.',signup:'https://my.mollie.com/dashboard/signup?lang=en',guide:'https://help.mollie.com/hc/en-gb/articles/210709969-How-do-I-create-an-account',ready:['Company details and stakeholder information','Live website URL','Business bank account','ID for legal representatives','Mollie account email','Optional Mollie payment link'],steps:['Create your Mollie account.','Open Start setup in the Mollie Dashboard.','Enter your business and website details.','Activate the payment methods you want to offer.','Finish verification and add your bank account for payouts.','Return to TradeFlow and record the non-secret details below.']},
 {code:'revolut',name:'Revolut Business',description:'Business banking plus online payment acceptance and Payment Links.',signup:'https://www.revolut.com/en-GB/business/',guide:'https://www.revolut.com/business/business-resources-onboarding-guide/',ready:['Full name, date of birth and nationality','Residential address and postcode','Government ID','Business legal and registration details','Registered and operating business address','Business activity description and website','Revolut Business account email','Merchant account for Payment Links/online payments'],steps:['Open a Revolut Business account.','Complete identity and business verification.','Provide registered and operating address details.','Choose the Business plan and complete account setup.','Set up the Merchant account/payment acceptance features you intend to use.','Return to TradeFlow and record the non-secret details below.']}
];
let paymentProviderRows=[];
function providerRow(code){return paymentProviderRows.find(x=>x.provider===code&&x.connection_type==='customer_payments')||null}
function providerStatus(row){
 if(!row)return 'Not set up';
 const m=row.metadata||{};
 if(m.setup_complete)return 'Setup recorded';
 if(row.status==='active')return 'Connected';
 if(row.status==='onboarding')return 'Setup in progress';
 return row.status||'Not set up';
}
function renderPaymentProviders(){
 const host=$('payment-providers');if(!host)return;
 host.innerHTML='<div class="payment-provider-grid">'+PAYMENT_PROVIDERS.map(p=>{
   const row=providerRow(p.code),m=row?.metadata||{},selected=m.primary===true;
   const accountEmail=m.account_email||'',accountRef=row?.provider_account_id||'',paymentLink=m.payment_link||'',postcode=m.business_postcode||'';
   return '<article class="payment-provider-card '+(selected?'is-selected':'')+'" data-provider-card="'+esc(p.code)+'"><div class="panel-subheading"><div><h3>'+esc(p.name)+'</h3><div class="payment-provider-meta">'+esc(p.description)+'</div></div><span class="status-pill">'+esc(providerStatus(row))+'</span></div><div class="payment-provider-guide"><strong>Have these ready</strong><ul>'+p.ready.map(x=>'<li>'+esc(x)+'</li>').join('')+'</ul><strong>Setup steps</strong><ol>'+p.steps.map(x=>'<li>'+esc(x)+'</li>').join('')+'</ol></div><div class="payment-provider-actions"><a href="'+p.signup+'" target="_blank" rel="noopener">Open '+esc(p.name)+' signup</a><a href="'+p.guide+'" target="_blank" rel="noopener">Open official instructions</a><button type="button" class="primary provider-edit" data-provider="'+esc(p.code)+'">'+(row?'Edit setup':'Enter setup details')+'</button></div><div class="payment-provider-form" data-provider-form="'+esc(p.code)+'" hidden><div class="small"><strong>TradeFlow setup details</strong><br>These fields do not contain secret API keys. Enter only the non-secret information you want TradeFlow to remember.</div><div class="form-grid"><label>Provider account email<input class="pp-account-email" type="email" value="'+esc(accountEmail)+'" autocomplete="email"></label><label>Provider account / merchant ID<input class="pp-account-ref" value="'+esc(accountRef)+'" maxlength="200"></label><label>Payment link (if you use one)<input class="pp-payment-link" type="url" value="'+esc(paymentLink)+'" placeholder="https://..."></label><label>Business postcode<input class="pp-postcode" value="'+esc(postcode||businessPostcode||'')+'" readonly></label></div><label class="payment-provider-check"><input class="pp-primary" type="checkbox" '+(selected?'checked':'')+'> Use this as my primary customer payment provider</label><label class="payment-provider-check"><input class="pp-complete" type="checkbox" '+(m.setup_complete?'checked':'')+'> I have completed the provider setup and verification</label><div class="payment-provider-actions"><button type="button" class="primary provider-save" data-provider="'+esc(p.code)+'">Save payment setup</button><button type="button" class="provider-close" data-provider="'+esc(p.code)+'">Close</button></div><div class="small payment-provider-muted" style="margin-top:8px">TradeFlow will not ask for your provider password, secret key or bank login. Those remain with the payment provider.</div></div></article>';
 }).join('')+'</div>';
 host.querySelectorAll('.provider-edit').forEach(b=>b.onclick=()=>{const f=host.querySelector('[data-provider-form="'+b.dataset.provider+'"]');if(f)f.hidden=!f.hidden});
 host.querySelectorAll('.provider-close').forEach(b=>b.onclick=()=>{const f=host.querySelector('[data-provider-form="'+b.dataset.provider+'"]');if(f)f.hidden=true});
 host.querySelectorAll('.provider-save').forEach(b=>b.onclick=()=>savePaymentProvider(b.dataset.provider));
}
async function savePaymentProvider(code){
 const provider=PAYMENT_PROVIDERS.find(x=>x.code===code),card=document.querySelector('[data-provider-card="'+code+'"]');if(!provider||!card)return;
 const form=card.querySelector('[data-provider-form="'+code+'"]');
 const accountEmail=form.querySelector('.pp-account-email').value.trim().toLowerCase();
 const accountRef=form.querySelector('.pp-account-ref').value.trim();
 const paymentLink=form.querySelector('.pp-payment-link').value.trim();
 const postcode=form.querySelector('.pp-postcode').value.trim();
 const primary=form.querySelector('.pp-primary').checked;
 const complete=form.querySelector('.pp-complete').checked;
 try{
  if(primary){
   const others=await api('/rest/v1/payment_provider_connections?tenant_id=eq.'+encodeURIComponent(tenantId)+'&connection_type=eq.customer_payments&provider=neq.'+encodeURIComponent(code),{method:'PATCH',headers:{Prefer:'return=minimal'},body:JSON.stringify({metadata:{primary:false}})});
  }
  const metadata={account_email:accountEmail||null,payment_link:paymentLink||null,business_postcode:postcode||null,primary,setup_complete:complete};
  const existing=providerRow(code);
  if(existing){
   await api('/rest/v1/payment_provider_connections?id=eq.'+encodeURIComponent(existing.id)+'&tenant_id=eq.'+encodeURIComponent(tenantId),{method:'PATCH',headers:{Prefer:'return=minimal'},body:JSON.stringify({provider_account_id:accountRef||null,display_name:provider.name,country_code:'GB',default_currency:'GBP',status:'onboarding',metadata})});
  }else{
   await api('/rest/v1/payment_provider_connections?on_conflict=tenant_id,provider,connection_type',{method:'POST',headers:{Prefer:'resolution=merge-duplicates,return=minimal'},body:JSON.stringify({tenant_id:tenantId,provider:code,connection_type:'customer_payments',status:'onboarding',provider_account_id:accountRef||null,display_name:provider.name,country_code:'GB',default_currency:'GBP',livemode:true,metadata})});
  }
  paymentProviderRows=await api('/rest/v1/payment_provider_connections?tenant_id=eq.'+encodeURIComponent(tenantId)+'&connection_type=eq.customer_payments&select=id,provider,connection_type,status,provider_account_id,display_name,metadata');
  renderPaymentProviders();msg(provider.name+' payment setup saved.','success');
 }catch(e){msg(e.message||String(e),'error')}
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
  paymentProviderRows=await api('/rest/v1/payment_provider_connections?tenant_id=eq.'+encodeURIComponent(tenantId)+'&connection_type=eq.customer_payments&select=id,provider,connection_type,status,provider_account_id,display_name,metadata');\n  renderPaymentProviders();\n  const defaults=[
   {method_code:'card',display_name:'Credit or debit card',enabled:true,sort_order:10},
   {method_code:'link',display_name:'Link',enabled:true,sort_order:20},
   {method_code:'klarna',display_name:'Klarna',enabled:true,sort_order:30},
   {method_code:'amazon_pay',display_name:'Amazon Pay',enabled:true,sort_order:40}
  ];
  await api('/rest/v1/tenant_payment_methods?on_conflict=tenant_id,method_code',{
   method:'POST',
   headers:{Prefer:'resolution=merge-duplicates,return=minimal'},
   body:JSON.stringify(defaults.map(x=>({...x,tenant_id:tenantId})))
  });
  const rows=await api('/rest/v1/tenant_payment_methods?select=id,method_code,display_name,enabled,sort_order&tenant_id=eq.'+encodeURIComponent(tenantId)+'&method_code=in.(card,link,klarna,amazon_pay)&order=sort_order');
  $('stripe-methods').innerHTML=rows?.length?rows.map(x=>{
    const required=x.method_code==='card';
    return '<div class="shipping-provider-card" style="display:flex;justify-content:space-between;align-items:center;gap:18px"><div><strong>'+esc(x.display_name)+'</strong><div class="small">'+(required?'Required base payment method for TradeFlow checkout.':'Customers will only see this method when it is enabled here and Stripe considers it eligible.')+'</div></div><label style="display:flex;align-items:center;gap:8px;white-space:nowrap"><input type="checkbox" class="stripe-method-toggle" data-method-id="'+esc(x.id)+'" data-method-code="'+esc(x.method_code)+'" '+(x.enabled?'checked':'')+(required?' disabled':'')+'> '+(x.enabled?'Enabled':'Disabled')+'</label></div>';
  }).join(''):'<div class="empty">No Stripe payment methods configured.</div>';
  document.querySelectorAll('.stripe-method-toggle').forEach(el=>el.addEventListener('change',async()=>{
    const id=el.dataset.methodId;
    const enabled=el.checked;
    el.disabled=true;
    try{
      await api('/rest/v1/tenant_payment_methods?id=eq.'+encodeURIComponent(id),{method:'PATCH',headers:{Prefer:'return=minimal'},body:JSON.stringify({enabled})});
      msg('Payment method setting saved.','success');
    }catch(e){
      el.checked=!enabled;
      msg(e.message||String(e),'error');
    }finally{el.disabled=false}
  }));
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

