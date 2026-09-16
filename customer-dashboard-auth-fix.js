/* TradeFlow customer-dashboard bootstrap.
 * The customer dashboard uses the Supabase publishable key only.
 * This file runs before the main dashboard controller so the controller
 * always has its test-lab connection key on first load. Authentication,
 * navigation and sign-out remain owned by customer-dashboard.js.
 */
(()=>{
  const KEY='sb_publishable_AvcMgtUKV0O5k8H6k94mZQ_qH4pEIS9';
  const STORAGE='tradeflow_testlab_publishable_key';
  if(!localStorage.getItem(STORAGE))localStorage.setItem(STORAGE,KEY);
})();
