# genius-lyrics.ps1
# Open Genius search page for the currently playing track (Spotify, Apple Music, etc.)
# Must be run in Windows PowerShell 5.1

if ($PSVersionTable.PSEdition -eq 'Core') {
    Write-Host "This script requires Windows PowerShell 5.1, not PowerShell Core/7." -ForegroundColor Red
    Write-Host "Run it with 'powershell' instead of 'pwsh'." -ForegroundColor Yellow
    exit 1
}

Add-Type -AssemblyName System.Runtime.WindowsRuntime

# Get the generic AsTask method
$asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object { 
    $_.Name -eq 'AsTask' -and 
    $_.GetParameters().Count -eq 1 -and 
    $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' 
})[0]

# Await function that explicitly requires the result type
function Await($WinRtTask, $ResultType) {
    $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
    $netTask = $asTask.Invoke($null, @($WinRtTask))
    $netTask.Wait(-1) | Out-Null
    $netTask.Result
}

function Test-GeniusUrl($url) {
    try {
        $response = Invoke-WebRequest -Uri $url -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop 
        # Check if the page contains the error message or "Burrr!" in title
        if ($response.Content -match 'Oops! Page not found' -or $response.Content -match 'Burrr!') {
            return $false
        }
        return $true
    }
    catch {
        return $false
    }
}

try {
    # Load WinRT types
    [Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager, Windows.Media.Control, ContentType = WindowsRuntime] | Out-Null
    [Windows.Media.Control.GlobalSystemMediaTransportControlsSession, Windows.Media.Control, ContentType = WindowsRuntime] | Out-Null
    
    # Request session manager
    $sessionManagerAsync = [Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager]::RequestAsync()
    $manager = Await $sessionManagerAsync ([Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager])
    
    # Get current session
    $session = $manager.GetCurrentSession()
    if (-not $session) {
        Write-Host "No active media session found. Play something in Spotify, YouTube, etc."
        exit 1
    }
    
    # Get media properties
    $propsAsync = $session.TryGetMediaPropertiesAsync()
    $props = Await $propsAsync ([Windows.Media.Control.GlobalSystemMediaTransportControlsSessionMediaProperties])
    
    $artist = $props.Artist
    $title  = $props.Title
    $appId  = $session.SourceAppUserModelId
    
    if ([string]::IsNullOrWhiteSpace($artist) -or [string]::IsNullOrWhiteSpace($title)) {
        Write-Host "Could not read track info (artist or title empty)."
        Write-Host "Source app: $appId"
        exit 1
    }
    
	# If artist ends in VEVO, parse from title
if ($artist -like '*VEVO') {
    $parts = $title -split ' - ', 2
    if ($parts.Count -eq 2) {
        $artist = $parts[0]
        $title = $parts[1]
    }
}
	
	
    # Clean up artist name - remove album info after em dash, hyphen, or parentheses
    $cleanArtist = $artist -replace '\s*[—–-]\s*.*$', '' -replace '\s*\(.*$', ''
    
    # Clean up title - remove remaster info, version info, etc.
    $cleanTitle = $title -replace '\s*\(.*?\)', '' -replace '\s*\[.*?\]', '' -replace '\s*-\s*\d{4}\s*.*$', ''
    
    # Convert to URL-friendly format using invariant culture 
    $urlArtist = $cleanArtist.Trim().ToLowerInvariant() -replace '[^\w\s-]', '' -replace '\s+', '-' -replace '-+', '-'
    $urlTitle = $cleanTitle.Trim().ToLowerInvariant() -replace '[^\w\s-]', '' -replace '\s+', '-' -replace '-+', '-'
    
    Write-Host "Detected from: $appId"
    Write-Host "Artist: $cleanArtist"
    Write-Host "Title : $cleanTitle"
    
    # Direct URL
    $directUrl = "https://genius.com/$urlArtist-$urlTitle-lyrics"
    
    Write-Host "Checking if lyrics page exists..."
    $urlExists = Test-GeniusUrl $directUrl
    
    if ($urlExists) {
        Write-Host "Opening direct: $directUrl"
        Start-Process $directUrl
    }
    else {
        Write-Host "Direct URL not found, opening search instead..."
        $query = [System.Uri]::EscapeDataString("$cleanArtist $cleanTitle")
        $searchUrl = "https://genius.com/search?q=$query"
        Write-Host "Opening search: $searchUrl"
        Start-Process $searchUrl
    }
}
catch {
    Write-Host "Error: $_"
    Write-Host "Make sure you're running Windows PowerShell 5.1 (not PowerShell Core) and have media playing."
    exit 1
}
