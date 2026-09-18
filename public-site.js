const SUPABASE_URL='https://twfbmjwwqzxdxvclxbun.supabase.co';
const KEY_STORAGE='tradeflow_subscriber_publishable_key';
const KEY=localStorage.getItem(KEY_STORAGE)||localStorage.getItem('tradeflow_testlab_publishable_key')||localStorage.getItem('tradeflow_platform_admin_publishable_key')||null;
const params=new URLSearchParams(location.search);
const tenantId=params.get('tenant_id');
const hostname=location.hostname;
const $=id=>document.getElementById(id);
async function api(path){
  if(!KEY)throw new Error('TradeFlow connection is not configured.');
  const headers=new Headers({'apikey':KEY,'Content-Type':'application/json'});
  const response=await fetch(`${SUPABASE_URL}${path}`,{headers});
  const text=await response.text();let body=null;try{body=text?JSON.parse(text):null}catch{body=text}
  if(!response.ok)throw new Error(body?.message||body?.msg||body?.error||text||`HTTP ${response.status}`);
  return body;
}
function applyContent(content){
  const site=content?.site||{};
  const theme=site.theme||{};
  document.documentElement.style.setProperty('--accent',theme.accent||'#c46a2b');
  const name=site.name||'TradeFlow';
  $('site-name').textContent=name;
  $('footer-name').textContent=name;
  $('headline').textContent=site.homepage?.headline||'Buy, sell and trade with confidence.';
  document.title=name;
  const target=tenantId?`customer-dashboard.html?tenant_id=${encodeURIComponent(tenantId)}`:'customer-dashboard.html';
  $('customer-login').href=target;
  $('start-buying').href=target;
  document.querySelectorAll('.features a').forEach(a=>a.href=target);
}
async function loadByTenant(){
  if(!tenantId)throw new Error('No subscriber tenant was supplied. Open the public site with its tenant_id or active domain.');
  const rows=await api('/rest/v1/rpc/get_published_sites');
  const selected=Array.isArray(rows)?rows.find(r=>r.tenant_id===tenantId):null;
  if(!selected)throw new Error('No published website was found for this subscriber.');
  applyContent(selected.content);
}
async function loadByHostname(){
  if(tenantId)return loadByTenant();
  if(!hostname||hostname==='localhost')return loadByTenant();
  const rows=await api(`/rest/v1/published_site_index?select=tenant_id,hostname,revision_number,content,published_at&hostname=eq.${encodeURIComponent(hostname)}&limit=1`);
  if(!Array.isArray(rows)||rows.length!==1)throw new Error('This domain is not connected to a published TradeFlow subscriber website.');
  applyContent(rows[0].content);
}
(async()=>{try{await loadByHostname();}catch(error){$('site-name').textContent='Website unavailable';$('headline').textContent=error.message||String(error);$('status').textContent='Unable to load subscriber website';$('status').style.display='block';}})();
