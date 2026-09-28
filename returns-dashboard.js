const SUPABASE_URL='https://twfbmjwwqzxdxvclxbun.supabase.co';
let key=null,session=null,tenantId=null,rows=[];

const $=id=>document.getElementById(id);
const esc=v=>String(v??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]||c));

function msg(t,type=''){
  const e=$('message');
  if(!e)return;
  e.textContent=t||'';
  e.className=('small '+type).trim();
}

async function api(path,o={}){
  const a=await window.tradeflowSubscriberAuthReady;
  key=a?.key||null;
  session=a?.session||null;
  tenantId=a?.tenantId||null;

  if(!key||!session?.access_token||!tenantId){
    throw Error('This Returns workspace requires a signed-in subscriber account.');
  }

  const h=new Headers(o.headers||{});
  h.set('apikey',key);
  h.set('Authorization','Bearer '+session.access_token);
  if(o.body)h.set('Content-Type','application/json');

  const r=await fetch(SUPABASE_URL+path,{...o,headers:h});
  const t=await r.text();
  let b=null;
  try{b=t?JSON.parse(t):null}catch{b=t}
  if(!r.ok)throw Error(b?.message||b?.hint||b?.details||b?.error||t||('HTTP '+r.status));
  return b;
}

async function load(){
  const target=$('returns');
  if(target)target.innerHTML='<div class="empty">Loading…</div>';

  try{
    const a=await window.tradeflowSubscriberAuthReady;
    const memberships=Array.isArray(a?.memberships)?a.memberships:[];
    const membership=memberships.find(x=>x.tenant_id===a?.tenantId)||memberships[0]||{};

    tenantId=membership.tenant_id||a?.tenantId||null;
    if(!tenantId||tenantId==='null'||tenantId==='undefined'){
      throw Error('No valid subscriber tenant is selected. Please sign in again.');
    }

    $('business-name').textContent=membership.tenant_name||membership.business_name||a?.tenants?.[tenantId]||'TradeFlow';

    rows=await api('/rest/v1/rpc/subscriber_get_returns',{
      method:'POST',
      body:JSON.stringify({p_tenant_id:tenantId})
    })||[];

    rows=Array.isArray(rows)?rows:[];
    render();
    msg(rows.length+' return(s) loaded.','success');
  }catch(e){
    msg(e.message||String(e),'error');
    if(target)target.innerHTML='<div class="empty">'+esc(e.message||String(e))+'</div>';
  }
}

function render(){
  const target=$('returns');
  if(!target)return;

  if(!rows.length){
    target.innerHTML='<div class="empty">No returns have been requested.</div>';
    return;
  }

  target.innerHTML='<div class="return-list">'+rows.map(r=>{
    const type=r.return_type==='customer_retail'
      ?'Customer retail return'
      :r.return_type==='acquisition'
        ?'Acquisition return'
        :r.return_type||'Return';

    const status=(r.status||'—').replace(/_/g,' ');
    const statusClass=(r.status||'unknown').replace(/[^a-z0-9_-]/gi,'-');

    return '<article class="return-tile">'+
      '<div class="return-tile-head">'+
        '<div><div class="return-reference">'+esc(r.return_reference||'Return request')+'</div>'+
        '<div class="return-type">'+esc(type)+'</div></div>'+
        '<span class="return-status '+statusClass+'">'+esc(status)+'</span>'+
      '</div>'+
      '<div class="return-details">'+
        '<div class="return-detail"><span>Reason</span><strong>'+esc(r.reason||r.reason_code||'—')+'</strong></div>'+
        '<div class="return-detail"><span>Refund</span><strong>'+(r.refund_amount==null?'—':esc((r.currency||'GBP')+' '+r.refund_amount))+'</strong></div>'+
        '<div class="return-detail"><span>Requested</span><strong>'+esc(r.requested_at?new Date(r.requested_at).toLocaleString('en-GB'):'—')+'</strong></div>'+
      '</div>'+
    '</article>';
  }).join('');
}

document.addEventListener('DOMContentLoaded',()=>{
  $('refresh')?.addEventListener('click',load);
  $('sign-out')?.addEventListener('click',()=>window.tradeflowSubscriberSignOut?.());
  load();
});
