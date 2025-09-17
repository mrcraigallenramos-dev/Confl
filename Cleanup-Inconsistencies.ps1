# Cleanup-Inconsistencies.ps1
# Removes obsolete items and fixes remaining inconsistencies

Set-StrictMode -Version Latest

Write-Host "=== Repository Cleanup & Consistency Fixes ===" -ForegroundColor Green

# 1) Remove the garbage "You" entity
Write-Host "Removing garbage 'You' entity..." -ForegroundColor Yellow
$youFile = Get-ChildItem -Path "canonical/misc" -Filter *.yaml | Where-Object {
    (Get-Content $_.FullName -Raw) -match 'name:\s*You'
}
if ($youFile) {
    Write-Host " - Deleting $($youFile.Name) (garbage entity)"
    Remove-Item $youFile.FullName -Force
} else {
    Write-Host " - 'You' entity not found"
}

# 2) Remove any remaining "Corlex" files (should be "Corlexi" now)
Write-Host "Checking for obsolete 'Corlex' files..." -ForegroundColor Yellow
Get-ChildItem -Path "canonical/characters" -Filter *.yaml | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -match 'name:\s*Corlex\s*$') {
        Write-Host " - WARNING: Found Corlex file: $($_.Name) (should be Corlexi)" -ForegroundColor Red
        Write-Host "   Please verify this file was properly renamed or remove it manually"
    }
}

# 3) Clean up empty factions directory
Write-Host "Cleaning up factions directory..." -ForegroundColor Yellow
if (Test-Path "canonical/factions") {
    $factionsFiles = Get-ChildItem -Path "canonical/factions" -Filter *.yaml
    if ($factionsFiles.Count -eq 0) {
        Write-Host " - Removing empty canonical/factions directory"
        Remove-Item "canonical/factions" -Force -Recurse
    } else {
        Write-Host " - Factions directory contains $($factionsFiles.Count) files:"
        $factionsFiles | ForEach-Object { Write-Host "   - $($_.Name)" }
    }
} else {
    Write-Host " - canonical/factions already removed"
}

# 4) Remove tiny/empty files (under 40 bytes)
Write-Host "Removing tiny/empty files..." -ForegroundColor Yellow
Get-ChildItem -Recurse -File | Where-Object { $_.Length -lt 40 } | ForEach-Object {
    Write-Host " - Deleting tiny file: $($_.FullName) ($($_.Length) bytes)"
    Remove-Item $_.FullName -Force
}

# 5) Fix YAML escape sequences in canonical files
Write-Host "Fixing YAML escape sequences..." -ForegroundColor Yellow
Get-ChildItem -Path "canonical" -Filter *.yaml -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $originalContent = $content
    
    # Fix common escape sequence artifacts
    $content = $content -replace '\\n\s*\\n\s*', "`n`n"
    $content = $content -replace '\\\s+', ' '
    $content = $content -replace '\\n\s*', "`n"
    
    if ($content -ne $originalContent) {
        Write-Host " - Fixed escape sequences in $($_.Name)"
        Set-Content -Path $_.FullName -Value $content
    }
}

# 6) Check for inconsistent character names across systems
Write-Host "Checking character name consistency..." -ForegroundColor Yellow
$canonicalChars = @()
Get-ChildItem -Path "canonical/characters" -Filter *.yaml | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -match 'name:\s*(\w+)') {
        $canonicalChars += $matches[1]
    }
}

$coreChars = @()
if (Test-Path "Characters/Core") {
    Get-ChildItem -Path "Characters/Core" -Filter *.md | ForEach-Object {
        $name = $_.BaseName -replace '\s*\(.*?\)', ''  # Remove parentheses
        $coreChars += $name
    }
}

$dossierChars = @()
if (Test-Path "character_dossiers") {
    Get-ChildItem -Path "character_dossiers" -Filter *_Dossier.md | ForEach-Object {
        $name = $_.BaseName -replace '_Dossier$', ''
        $dossierChars += $name
    }
}

Write-Host " - Canonical characters: $($canonicalChars -join ', ')"
Write-Host " - Core characters: $($coreChars -join ', ')"
Write-Host " - Dossier characters: $($dossierChars -join ', ')"

# 7) Remove duplicate or orphaned provenance entries
Write-Host "Checking provenance index..." -ForegroundColor Yellow
if (Test-Path "provenance_index.json") {
    $provenance = Get-Content "provenance_index.json" | ConvertFrom-Json
    $provenanceCount = ($provenance.PSObject.Properties | Measure-Object).Count
    Write-Host " - Provenance entries: $provenanceCount"
    
    # Check for suspicious duplicate entries (all pointing to same line ranges)
    $duplicateRanges = $provenance.PSObject.Properties.Value | 
        Group-Object { "$($_.line_start)-$($_.line_end)" } | 
        Where-Object { $_.Count -gt 5 }
    
    if ($duplicateRanges) {
        Write-Host " - WARNING: Found $($duplicateRanges.Count) suspicious duplicate line ranges" -ForegroundColor Red
        $duplicateRanges | ForEach-Object {
            Write-Host "   - Lines $($_.Name): $($_.Count) entities"
        }
    }
}

# 8) Check for malformed YAML structure
Write-Host "Validating YAML structure..." -ForegroundColor Yellow
Get-ChildItem -Path "canonical" -Filter *.yaml -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    
    # Check for required fields
    $hasId = $content -match '^id:\s*[a-f0-9-]{36}$'
    $hasName = $content -match '^name:\s*\w+'
    $hasCategory = $content -match '^category:\s*(characters|locations|factions|magic|events|scenes|misc)$'
    $hasDescription = $content -match '^description:'
    
    if (-not ($hasId -and $hasName -and $hasCategory -and $hasDescription)) {
        Write-Host " - WARNING: Malformed YAML in $($_.Name)" -ForegroundColor Red
        if (-not $hasId) { Write-Host "   - Missing or invalid ID" }
        if (-not $hasName) { Write-Host "   - Missing name" }
        if (-not $hasCategory) { Write-Host "   - Missing or invalid category" }
        if (-not $hasDescription) { Write-Host "   - Missing description" }
    }
}

# 9) Remove trailing whitespace from all text files
Write-Host "Removing trailing whitespace..." -ForegroundColor Yellow
Get-ChildItem -Recurse -File | Where-Object { $_.Extension -in @('.md', '.yaml', '.json', '.txt') } | ForEach-Object {
    $content = Get-Content $_.FullName
    $cleanedContent = $content | ForEach-Object { $_.TrimEnd() }
    
    if (Compare-Object $content $cleanedContent) {
        Write-Host " - Cleaned trailing whitespace in $($_.Name)"
        Set-Content -Path $_.FullName -Value $cleanedContent
    }
}

Write-Host "=== Cleanup Complete ===" -ForegroundColor Green
Write-Host "Review the changes above, then run:" -ForegroundColor Cyan
Write-Host "  git add -A"
Write-Host "  git commit -m 'Cleanup: remove garbage entities, fix YAML, trim whitespace'"
Write-Host "  git push"
