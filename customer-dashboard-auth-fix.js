/* TradeFlow customer-dashboard bootstrap.
 * The customer dashboard uses the TradeFlow Supabase publishable key only.
 * This file runs before the main dashboard controller so the controller
 * always has the correct test-lab connection key on first load. Authentication,
 * navigation and sign-out remain owned by customer-dashboard.js.
 */
(()=>{
  const KEY='sb_publishable_Plc9kcyye1asKxTJOmGdhQ_dP_LX59o';
  const STORAGE='tradeflow_testlab_publishable_key';
  // Replace any stale test-lab key from the previous repair so the main
  // dashboard controller cannot initialise against the wrong Supabase project.
  localStorage.setItem(STORAGE,KEY);
})();
