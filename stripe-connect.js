(() => {
  const SUPABASE_URL = "https://twfbmjwwqzxdxvclxbun.supabase.co";
  const button = document.getElementById("verify-stripe-test");
  const output = document.getElementById("stripe-test-check-result");
  if (!button || !output) return;
  const show = (message, kind = "") => {
    output.textContent = message;
    output.className = "small" + (kind ? " " + kind : "");
  };
  button.addEventListener("click", async () => {
    button.disabled = true;
    show("Checking the Stripe test configuration…");
    try {
      const auth = await window.tradeflowSubscriberAuthReady;
      if (!auth?.session?.access_token || !auth?.tenantId || !auth?.key) {
        throw new Error("Sign in to the TEST subscriber account first.");
      }
      const response = await fetch(SUPABASE_URL + "/functions/v1/stripe-connect-diagnostic", {
        method: "POST",
        headers: {
          apikey: auth.key,
          Authorization: "Bearer " + auth.session.access_token,
          "Content-Type": "application/json"
        },
        body: JSON.stringify({ tenant_id: auth.tenantId })
      });
      const result = await response.json();
      if (!response.ok || !result.ok) throw new Error(result.error || "Stripe test check failed.");
      show(
        "Verified TEST Stripe platform: " + result.account_name +
        " · " + result.account_id +
        " · " + (result.country || "country not set") +
        ". Charges " + (result.charges_enabled ? "enabled" : "not enabled") +
        "; payouts " + (result.payouts_enabled ? "enabled" : "not enabled") +
        ". Read-only check only; no account or payment was created.",
        "success"
      );
    } catch (error) {
      show(error?.message || "Unable to verify the Stripe test setup.", "error");
    } finally {
      button.disabled = false;
    }
  });
})();
