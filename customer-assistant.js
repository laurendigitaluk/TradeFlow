let customerAssistantReady=false;
window.addEventListener('DOMContentLoaded',async()=>{
 const status=document.getElementById('assistant-status'),form=document.getElementById('assistant-form'),q=document.getElementById('assistant-question'),messages=document.getElementById('messages');
 const add=(text,kind='system')=>{const el=document.createElement('div');el.className='assistant-message '+kind;el.textContent=text;messages.appendChild(el);messages.scrollTop=messages.scrollHeight;};
 const ready=window.tradeflowCustomerAuthReady?await window.tradeflowCustomerAuthReady:null;
 const tenantId=window.TRADEFLOW_CUSTOMER_TENANT_ID||'';
 const raw=sessionStorage.getItem('tradeflow_customer_session:'+tenantId)||'';let stored=null;try{stored=raw?JSON.parse(raw):null}catch{} const token=stored?.access_token||window.tradeflowPendingAuthSession?.access_token||'';
 const key=window.TRADEFLOW_CONFIG?.supabasePublishableKey||'';
 if(!tenantId||!token||!key){status.textContent='Sign in to use the customer assistant.';return;}
 customerAssistantReady=true;
 status.textContent='Customer assistant connected.';
 try{
  const p=await fetch(window.TRADEFLOW_CONFIG.supabaseUrl+'/functions/v1/tradeflow-assistant',{method:'POST',headers:{apikey:key,Authorization:'Bearer '+token,'Content-Type':'application/json'},body:JSON.stringify({tenant_id:tenantId,question:'Summarise my current account status.',mode:'help',audience:'customer'})});
  const b=await p.json().catch(()=>({}));
  const ctx=b?.assistant?.customer_context;
  document.getElementById('status-selling').textContent=String((ctx?.buying_requests||[]).length);
  document.getElementById('status-orders').textContent=String((ctx?.retail_orders||[]).length);
  document.getElementById('status-returns').textContent=String((ctx?.returns||[]).length);
 }catch{}
 form.addEventListener('submit',async e=>{
  e.preventDefault();const question=q.value.trim();if(!question)return;
  add(question,'user');q.value='';status.textContent='Checking your account and approved TradeFlow guidance…';
  try{
   const r=await fetch(window.TRADEFLOW_CONFIG.supabaseUrl+'/functions/v1/tradeflow-assistant',{method:'POST',headers:{apikey:key,Authorization:'Bearer '+token,'Content-Type':'application/json'},body:JSON.stringify({tenant_id:tenantId,question,mode:'help',audience:'customer'})});
   const b=await r.json().catch(()=>({}));if(!r.ok)throw Error(b.error||'Assistant request failed.');
   const k=b?.assistant?.knowledge||[];const ctx=b?.assistant?.customer_context;
   if(b?.assistant?.fallback_answer)add(b.assistant.fallback_answer,'system');
   else add('The customer assistant gateway is connected, but no approved guidance matched this question.','system');
   if(ctx){document.getElementById('status-selling').textContent=String((ctx.buying_requests||[]).length);document.getElementById('status-orders').textContent=String((ctx.retail_orders||[]).length);document.getElementById('status-returns').textContent=String((ctx.returns||[]).length);}
   status.textContent='Gateway response received. Provider: none.';
  }catch(err){add(err.message||String(err),'system');status.textContent='Assistant request failed.';}
 });
});
