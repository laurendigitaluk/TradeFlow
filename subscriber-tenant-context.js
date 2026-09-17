// TradeFlow subscriber test-lab tenant context.
// This runs before subscriber workspace controllers so pages opened without tenant_id
// inherit the authenticated test tenant instead of leaving category selectors blank.
(()=>{
  const KEY='tradeflow_testlab_session';
  const TENANTS={
    'f50fb889-c615-4e55-84d4-f0fd9f48b0b0':'Test Business A',
    '373598f0-7d35-41be-8ed2-3cc7ee9709c7':'Test Business B'
  };
  const USER_TENANT={
    '46cee9fa-2ead-42b2-8e55-b81c79c5b728':'f50fb889-c615-4e55-84d4-f0fd9f48b0b0',
    '9cc88fc3-7d03-4e99-b97f-6205ac658daf':'f50fb889-c615-4e55-84d4-f0fd9f48b0b0',
    '52f51902-cbc3-45c9-838c-1326f2e65906':'f50fb889-c615-4e55-84d4-f0fd9f48b0b0',
    '5ba9ac5d-53a0-4edf-bcdb-c9003e5a5eee':'373598f0-7d35-41be-8ed2-3cc7ee9709c7'
  };
  let session=null;try{session=JSON.parse(localStorage.getItem(KEY)||'null')}catch{}
  const params=new URLSearchParams(location.search);
  let tenantId=params.get('tenant_id');
  if(!TENANTS[tenantId]) tenantId=localStorage.getItem('tradeflow_testlab_tenant_id');
  if(!TENANTS[tenantId]) tenantId=USER_TENANT[session?.user?.id];
  if(TENANTS[tenantId]){
    localStorage.setItem('tradeflow_testlab_tenant_id',tenantId);
    if(params.get('tenant_id')!==tenantId){
      params.set('tenant_id',tenantId);
      history.replaceState(null,'',`${location.pathname}?${params.toString()}`);
    }
    document.documentElement.dataset.tradeflowTenantId=tenantId;
    document.documentElement.dataset.tradeflowTenantName=TENANTS[tenantId];
  }
})();