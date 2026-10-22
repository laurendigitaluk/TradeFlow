(()=> {
  const checkbox = () => document.getElementById("use-shared-evidence");
  const message = () => document.getElementById("shared-evidence-message");
  function show(text, type = "") {
    const el = message();
    if (el) { el.textContent = text; el.className = "small " + type; }
  }
  async function run() {
    const input = checkbox();
    if (!input) return;
    input.disabled = true;
    try {
      const auth = await window.tradeflowSubscriberAuthReady;
      // Fail closed: never fall back to the LIVE Supabase project on a misconfigured page.
      const supabaseUrl = window.TRADEFLOW_CONFIG?.supabaseUrl;
      if (!supabaseUrl) throw new Error("TradeFlow environment configuration is missing. No settings were changed.");
      if (!auth?.session?.access_token || !auth?.tenantId || !auth?.key) {
        throw new Error("Subscriber sign-in required to load this preference.");
      }
      const tenantId = auth.tenantId;
      const headers = {
        apikey: auth.key,
        Authorization: "Bearer " + auth.session.access_token
      };
      const response = await fetch(
        supabaseUrl + "/rest/v1/tenants?select=id,settings&id=eq." + encodeURIComponent(tenantId),
        { headers }
      );
      const raw = await response.text();
      let data;
      try { data = raw ? JSON.parse(raw) : null; } catch { data = raw; }
      if (!response.ok) throw new Error(data?.message || data?.hint || "Could not load shared evidence preference.");
      const settings = Array.isArray(data) ? (data[0]?.settings || {}) : {};
      input.checked = settings.use_shared_evidence !== false;
      input.disabled = false;
      show(input.checked
        ? "Shared market evidence is enabled for this business."
        : "Shared market evidence is disabled for this business.");
      input.addEventListener("change", async () => {
        const requested = input.checked;
        input.disabled = true;
        show("Saving shared evidence preference…");
        try {
          const save = await fetch(supabaseUrl + "/rest/v1/rpc/subscriber_set_shared_evidence_preference", {
            method: "POST",
            headers: { ...headers, "Content-Type": "application/json" },
            body: JSON.stringify({ p_tenant_id: tenantId, p_enabled: requested })
          });
          const saveRaw = await save.text();
          let result;
          try { result = saveRaw ? JSON.parse(saveRaw) : null; } catch { result = saveRaw; }
          if (!save.ok) throw new Error(result?.message || result?.details || result?.hint || "Could not save shared evidence preference.");
          const enabled = result?.use_shared_evidence ?? requested;
          input.checked = enabled;
          show(enabled
            ? "Saved. Shared market evidence is enabled for this business."
            : "Saved. Shared market evidence is disabled for this business.", "success");
          window.dispatchEvent(new CustomEvent("tradeflow:shared-evidence-preference-changed", { detail: { enabled } }));
        } catch (error) {
          input.checked = !requested;
          show(error.message || "Could not save shared evidence preference.", "error");
        } finally {
          input.disabled = false;
        }
      });
    } catch (error) {
      input.checked = true;
      input.disabled = true;
      show((error.message || "Could not load shared evidence preference.") + " Please refresh or contact the TradeFlow owner.", "error");
    }
  }
  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", run, { once: true });
  else run();
})();
