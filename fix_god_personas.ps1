# Fix-GodPersonas.ps1
# Run this in the repo root: .\Fix-GodPersonas.ps1

Set-StrictMode -Version Latest

# 1) Rename Corlex → Corlexi in canonical character YAMLs
Write-Host "Renaming Corlex → Corlexi..."
Get-ChildItem -Path "canonical/characters" -Filter *.yaml | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -match '^name:\s*Corlex$') {
        Write-Host " - Processing $($_.Name)"
        $content = $content -replace '^(name:\s*)Corlex$', '${1}Corlexi'
        Set-Content -Path $_.FullName -Value $content
    }
}

# 2) Fix category for Blemo (Mobel) persona
Write-Host "Fixing Blemo category..."
$f = Get-ChildItem -Path "canonical/factions" -Filter *.yaml | Where-Object {
    (Get-Content $_.FullName -Raw) -match '^name:\s*Blemo$'
}
if ($f) {
    Write-Host " - Editing $($f.Name)"
    (Get-Content $f.FullName -Raw) `
      -replace '^(category:\s*)factions$', '${1}characters' |
      Set-Content -Path $f.FullName
    Move-Item -Path $f.FullName -Destination "canonical/characters/"
} else {
    Write-Host " - Blemo YAML not found in canonical/factions"
}

# 3) Create new GUID and YAML for Eries (Decay persona)
Write-Host "Adding Eries (Decay persona)..."
$eriesGuid = [guid]::NewGuid().ToString()
$eriesFile = "canonical/characters/$eriesGuid.yaml"
if (-Not (Test-Path $eriesFile)) {
    @"
id: $eriesGuid
name: Eries
category: characters
description: |
  Eries

  **Mortal Mask:** Eries is a harbinger of entropy and necessary endings, believing that decay renews the cycle of creation.
source:
  file: TheConfluenceChronicles_RevisedStoryBible-AMasterclassinStrategicStorytelling.md
  section_heading: ''
  line_start: 4898
  line_end: 4940
  tag: uploaded_bibles
"@ | Set-Content -Path $eriesFile
    Write-Host " - Created $eriesGuid.yaml"
} else {
    Write-Host " - $eriesGuid.yaml already exists"
}

# 4) Update Core and Dossiers with Eries.md and Eries_Dossier.md stubs
Write-Host "Adding Core and dossier entries for Eries..."
$coreDir = "Characters/Core"
$dossierDir = "character_dossiers"

# Core profile
$coreFile = Join-Path $coreDir "Eries.md"
if (-Not (Test-Path $coreFile)) {
    @"
Eries
=====

tags: character/godpersona aliases: [The Harbinger of Decay] principle: "[[Decay]]" faction: "Independent" status: "Active"

| **Principle** | [[Decay]] (Seeri) |
|---------------|-------------------|
| **Mortal Mask** | A champion of necessary endings, Eries believes that entropy is the crucible of new life. |

Overview
--------

Eries embodies the principle of Decay, unleashing entropy to reset what has grown too rigid or broken.
"@ | Set-Content -Path $coreFile
    Write-Host " - Created Eries.md in Core"
} else {
    Write-Host " - Eries.md already exists in Core"
}

# Dossier
$dossierFile = Join-Path $dossierDir "Eries_Dossier.md"
if (-Not (Test-Path $dossierFile)) {
    @"
# Eries Dossier

**Principle:** Decay (Seeri)  
**Alias:** The Harbinger of Decay  

## Biography
- Once a cosmic force, Eries walked the mortal realms to sow the seeds of necessary endings.
- Views decay as a mercy, dissolving stagnation to make way for new growth.

## Abilities
- Commands rust, ash, and entropy.
- Can collapse structures and mental barriers alike.

## Arc Notes
- Serves as the counterbalance to Form and Wholeness.
- Ultimately guides protagonists to accept endings as part of the cycle.
"@ | Set-Content -Path $dossierFile
    Write-Host " - Created Eries_Dossier.md"
} else {
    Write-Host " - Eries_Dossier.md already exists"
}

Write-Host "All updates complete. Please review changes, then run:"
Write-Host "  git add canonical/characters canonical/factions Characters/Core character_dossiers"
Write-Host "  git commit -m 'Fix god-persona names: Corlexi, add Eries, unify categories'"
Write-Host "  git push"
