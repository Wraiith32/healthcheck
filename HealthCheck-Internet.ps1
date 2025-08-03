$internetHealthUrl = $env:HC_INTERNET
$testUrl = "https://1.1.1.1"  # Cloudflare DNS (fast and stable)

try {
    $response = Invoke-WebRequest -Uri $testUrl -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 400) {
        Write-Host "✅ Internet is up. Pinging Healthchecks.io..."
        Invoke-RestMethod -Uri $internetHealthUrl -Method Get
        Write-Host "📡 Internet Healthchecks.io ping sent successfully."
    }
    else {
        Write-Warning "⚠️ Received unexpected HTTP status code: $($response.StatusCode)"
    }
}
catch {
    Write-Warning "❌ Internet appears to be down or unreachable."
}
