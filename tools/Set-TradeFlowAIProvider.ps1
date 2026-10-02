param(
  [ValidateSet("none","gemma","openai","anthropic","google","subscriber")]
  [string]$Provider = "none",

  [string[]]$Allowed = @("none","gemma","openai","anthropic","google","subscriber"),

  [string]$ProjectRef = "twfbmjwwqzxdxvclxbun"
)

$config = @{
  provider = $Provider
  allowed = $Allowed
} | ConvertTo-Json -Compress

Write-Host "Setting TradeFlow TEST AI provider: $Provider"
Write-Host "Allowed providers: $($Allowed -join ', ')"

npx supabase secrets set "TRADEFLOW_AI_CONFIG=$config" --project-ref $ProjectRef

if ($LASTEXITCODE -ne 0) {
  throw "Supabase secret update failed."
}

Write-Host "TradeFlow TEST AI provider configuration updated."
