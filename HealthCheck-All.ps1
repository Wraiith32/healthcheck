# Define each service with name, process, web URL, and healthchecks.io ping URL
$plexUrl     = $env:HC_PLEX
$sonarrUrl   = $env:HC_SONARR
$radarrUrl   = $env:HC_RADARR
$sabnzbdUrl  = $env:HC_SABNZBD

$services = @(
    @{
        Name = "Plex"
        Process = "Plex Media Server"
        Url = "http://localhost:32400/web"
        HealthCheckUrl = $plexUrl
    },
    @{
        Name = "Sonarr"
        Process = "Sonarr.Console"
        Url = "http://localhost:8989"
        HealthCheckUrl = $sonarrUrl
    },
    @{
        Name = "Radarr"
        Process = "Radarr.Console"
        Url = "http://localhost:7878"
        HealthCheckUrl = $radarrUrl
    },
    @{
        Name = "SABnzbd"
        Process = "SABnzbd"
        Url = "http://localhost:8080"
        HealthCheckUrl = $sabnzbdUrl
    }
)

# Loop through each service and check its health
foreach ($service in $services) {
    $isHealthy = $false
    $name = $service.Name
    $proc = Get-Process -Name $service.Process -ErrorAction SilentlyContinue

    if ($proc) {
        Write-Host "✅ $name process is running."
        $isHealthy = $true
    } else {
        Write-Warning "❌ $name process is NOT running."
        $isHealthy = $false
    }

    # Check Web UI
    try {
        $response = Invoke-WebRequest -Uri $service.Url -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ $name web interface is responding."
            $isHealthy = $isHealthy -and $true
        } else {
            Write-Warning "⚠️ $name web interface returned status code: $($response.StatusCode)"
            $isHealthy = $false
        }
    }
    catch {
        Write-Warning "❌ $name web interface is NOT responding at $($service.Url)"
        $isHealthy = $false
    }

    # If both checks passed, ping Healthchecks.io
    if ($isHealthy) {
        try {
            Invoke-RestMethod -Uri $service.HealthCheckUrl -Method Get
            Write-Host "📡 $name pinged Healthchecks.io successfully."
        }
        catch {
            Write-Warning "⚠️ $name failed to ping Healthchecks.io."
        }
    }
}
