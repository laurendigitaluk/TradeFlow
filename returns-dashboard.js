const SUPABASE_URL='https://twfbmjwwqzxdxvclxbun.supabase.co';
let key=null,session=null,tenantId=null,rows=[];
const $=id=>document.getElementById(id);
const esc=v=>String(v??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]||c));
function msg(t,type=''){const e=$('message');if(!e)return;e.textContent=t||'';e.className=('small '+type).trim()}
async function api(path,o={}){
 const a=await window.tradeflowSubscriberAuthReady;
 key=a?.key||null;session=a?.session||null;tenantId=a?.tenantId||null;
 if(!key||!session?.access_token||!tenantId)throw Error('This Returns workspace requires a signed-in subscriber account.');
 const h=new Headers(o.headers||{});h.set('apikey',key);h.set('Authorization','Bearer '+session.access_token);
 if(o.body)h.set('Content-Type','application/json');
 const r=await fetch(SUPABASE_URL+path,{...o,headers:h});
 const t=await r.text();let b=null;try{b=t?JSON.parse(t):null}catch{b=t}
 if(!r.ok)throw Error(b?.message||b?.hint||b?.details||b?.error||t||('HTTP '+r.status));
 return b;
}
const next={requested:[['authorised','Authorise'],['rejected','Reject'],['closed','Close']],authorised:[['awaiting_return','Awaiting return']],awaiting_return:[['received','Mark received']],received:[['inspected','Mark inspected']],inspected:[['approved','Approve'],['rejected','Reject']],approved:[['refunded','Refund'],['replaced','Replace'],['closed','Close']],refunded:[['closed','Close']],replaced:[['closed','Close']],rejected:[['closed','Close']],closed:[]};
async function load(){
 try{
  const a=await window.tradeflowSubscriberAuthReady;
  const membership=(Array.isArray(a?.memberships)?a.memberships:[]).find(x=>x.tenant_id===a?.tenantId)||{};
  $('business-name').textContent=membership.tenant_name||membership.business_name||a?.tenants?.[a?.tenantId]||'TradeFlow';
  rows=await api('/rest/v1/returns?select=id,return_reference,return_type,status,customer_id,order_id,order_item_id,inventory_asset_id,reason_code,reason,customer_notes,staff_notes,requested_at,authorised_at,received_at,inspected_at,resolved_at,closed_at,refund_amount,currency&tenant_id=eq.'+encodeURIComponent(tenantId)+'&order=requested_at.desc')||[];
  rows=Array.isArray(rows)?rows:[];
  render();msg(rows.length+' return(s) loaded.','success');
 }catch(e){
  msg(e.message||String(e),'error');
  $('returns').innerHTML='<div class="empty">'+esc(e.message||String(e))+'</div>';
 }
}
function render(){
 if(!rows.length){$('returns').innerHTML='<div class="empty">No returns have been requested.</div>';return}
 $('returns').innerHTML='<div class="data-table"><div class="data-head"><span>Reference</span><span>Type</span><span>Status</span><span>Reason</span><span>Refund</span><span>Action</span></div>'+
 rows.map(r=>'<div class="data-row"><span>'+esc(r.return_reference)+'</span><span>'+esc(r.return_type)+'</span><span>'+esc(r.status)+'</span><span>'+esc(r.reason||r.reason_code||'—')+'</span><span>'+(r.refund_amount==null?'—':esc(r.currency)+' '+esc(r.refund_amount))+'</span><span>'+((next[r.status]||[]).map(([to,label])=>'<button type="button" data-id="'+esc(r.id)+'" data-from="'+esc(r.status)+'" data-to="'+esc(to)+'">'+label+'</button>').join(' ')||'—')+'</span></div>').join('')+'</div>';
 document.querySelectorAll('[data-id]').forEach(b=>b.onclick=()=>transition(b.dataset.id,b.dataset.from,b.dataset.to));
}
async function transition(id,from,to){
 try{
  msg('Changing return to '+to.replaceAll('_',' ')+'…');
  await api('/rest/v1/rpc/transition_workflow_entity',{method:'POST',body:JSON.stringify({p_tenant_id:tenantId,p_entity_type:'return',p_entity_id:id,p_expected_from:from,p_to_status:to,p_notes:null,p_metadata:{source:'returns-dashboard'}})});
  await load();msg('Return status updated.','success');
 }catch(e){msg(e.message||String(e),'error')}
}
$('refresh').onclick=load;
$('sign-out').onclick=()=>window.tradeflowSubscriberSignOut?.();
load();