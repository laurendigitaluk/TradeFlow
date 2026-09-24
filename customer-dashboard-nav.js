/* TradeFlow customer dashboard navigation.
 * Keeps customer portal navigation independent of the data controller.
 * Native hash navigation must remain available while the portal is hidden;
 * otherwise the navigation script itself can make the page appear completely inert.
 */
(()=>{
  const sectionIds=['overview','orders','valuations','returns','profile'];
  const SUPABASE_URL='https://twfbmjwwqzxdxvclxbun.supabase.co';
  const KEY_STORAGE='tradeflow_customer_publishable_key';
  const SESSION_STORAGE='tradeflow_customer_session';
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
    const portal=document.getElementById('portal');
    if(!show(location.hash.slice(1)||'overview',false)){
      document.querySelectorAll('a[href^="#"]').forEach(link=>link.classList.remove('active'));
    }
  };
  if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',bind,{once:true});
  else bind();
})();
