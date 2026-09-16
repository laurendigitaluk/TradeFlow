/* TradeFlow customer dashboard navigation.
 * Keeps customer portal navigation independent of the data controller.
 * Native hash navigation must remain available while the portal is hidden;
 * otherwise the navigation script itself can make the page appear completely inert.
 */
(()=>{
  const sectionIds=['overview','shop','orders','fulfilments','returns','buying','selling','offers','acquisitions','profile'];
  const SUPABASE_URL='https://twfbmjwwqzxdxvclxbun.supabase.co';
  const KEY_STORAGE='tradeflow_testlab_publishable_key';
  const SESSION_STORAGE='tradeflow_testlab_session';
  const tenantId=new URLSearchParams(location.search).get('tenant_id');
  const show=(id,updateHash=true)=>{
    const target=sectionIds.includes(id)?id:'overview';
    const portal=document.getElementById('portal');
    if(!portal||portal.hidden)return false;
    sectionIds.forEach(sectionId=>{
      const section=document.getElementById(sectionId);
      if(section)section.hidden=sectionId!==target;
    });
    document.querySelectorAll('a[href^="#"]').forEach(link=>{
      link.classList.toggle('active',link.getAttribute('href')===`#${target}`);
    });
    if(updateHash&&location.hash!==`#${target}`)history.replaceState(null,'',`#${target}`);
    const content=document.querySelector('.content');
    if(content)content.scrollIntoView({block:'start'});
    return true;
  };
  const loadBuyingCategories=async()=>{
    const select=document.getElementById('request-category');
    if(!select)return;
    const raw=localStorage.getItem(SESSION_STORAGE);
    const key=localStorage.getItem(KEY_STORAGE);
    if(!raw||!key||!tenantId)return;
    try{
      const session=JSON.parse(raw);
      if(!session?.access_token)return;
      const response=await fetch(`${SUPABASE_URL}/rest/v1/rpc/customer_get_buying_categories`,{
        method:'POST',
        headers:{apikey:key,Authorization:`Bearer ${session.access_token}`,'Content-Type':'application/json'},
        body:JSON.stringify({p_tenant_id:tenantId})
      });
      const text=await response.text();
      let data=[];try{data=text?JSON.parse(text):[];}catch{}
      if(!response.ok)throw Error(data?.message||data?.msg||data?.error||text||`HTTP ${response.status}`);
      select.innerHTML='<option value="">Select a category…</option>';
      for(const category of Array.isArray(data)?data:[]){
        const option=document.createElement('option');
        option.value=category.category_id;
        option.textContent=category.name;
        select.appendChild(option);
      }
      if(!Array.isArray(data)||!data.length)select.innerHTML='<option value="">No buying categories available</option>';
    }catch(error){
      console.error('TradeFlow customer buying categories failed:',error);
      select.innerHTML='<option value="">Unable to load categories</option>';
    }
  };
  const bind=()=>{
    document.querySelectorAll('a[href^="#"]').forEach(link=>{
      link.addEventListener('click',e=>{
        const id=link.getAttribute('href').slice(1);
        if(!sectionIds.includes(id))return;
        const portal=document.getElementById('portal');
        if(!portal||portal.hidden)return;
        e.preventDefault();
        show(id);
      });
    });
    window.addEventListener('hashchange',()=>show(location.hash.slice(1),false));
    window.addEventListener('tradeflow-auth-success',()=>loadBuyingCategories());
    if(!show(location.hash.slice(1)||'overview',false)){
      document.querySelectorAll('a[href^="#"]').forEach(link=>link.classList.remove('active'));
    }
    if(!document.getElementById('portal')?.hidden)loadBuyingCategories();
  };
  if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',bind,{once:true});
  else bind();
})();
