$PostFile = Get-ChildItem -Path "_posts" -Filter "*Bastard.md" | Select-Object -First 1

if (-not $PostFile) {
    Write-Host "[x] Error: Could not find the Basterd markdown file in _posts folder." -ForegroundColor Red
    exit
}

$MarkdownFile = $PostFile.FullName
$TargetDir = "assets/img/bastard"

if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
}

$Content = Get-Content -Path $MarkdownFile -Raw -Encoding UTF8

if ([string]::IsNullOrEmpty($Content)) {
    Write-Host "[x] Error: The file is empty or could not be read." -ForegroundColor Red
    exit
}

$Pattern = '!\[(.*?)\]\((https?://[^)\s]+)\)'
$Matches = [regex]::Matches($Content, $Pattern)

Write-Host "[+] Found $($Matches.Count) Medium images to download."

$Index = 1
foreach ($Match in $Matches) {
    $AltText = $Match.Groups[1].Value
    $Url = $Match.Groups[2].Value
    
    $CleanUrl = $Url.Split('?')[0]
    $Ext = [System.IO.Path]::GetExtension($CleanUrl)
    if (-not $Ext) { $Ext = ".png" }
    
    $NewFilename = "image_$Index$Ext"
    $LocalPath = Join-Path $TargetDir $NewFilename
    
    Write-Host "[~] Downloading image $Index..."
    try {
        Invoke-WebRequest -Uri $Url -OutFile $LocalPath -TimeoutSec 15
        
        $ChirpyStyle = "![${AltText}]({{ '/$TargetDir/$NewFilename' | relative_url }})"
        
        $OldString = $Match.Value
        $Content = $Content.Replace($OldString, $ChirpyStyle)
        
        Write-Host "[+] Saved to $LocalPath and updated Markdown."
        $Index++
    }
    catch {
        Write-Host "[x] Failed to download image from: $Url"
    }
}

Set-Content -Path $MarkdownFile -Value $Content -Encoding UTF8
Write-Host "[+] Done! All images downloaded and Markdown file updated successfully."