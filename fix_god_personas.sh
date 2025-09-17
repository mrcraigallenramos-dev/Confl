#!/usr/bin/env bash
set -euo pipefail

# 1) Rename Corlex → Corlexi in canonical character YAMLs
echo "Renaming Corlex → Corlexi..."
mapfile -t files_to_fix < <(grep -RlzE '^name:[[:space:]]*Corlexi?$' canonical/characters/*.yaml)
for file in "${files_to_fix[@]}"; do
  echo " - Processing $file"
  sed -i 's/^name:[[:space:]]*Corlex/name: Corlexi/' "$file"
done

# 2) Fix category for Blemo (Mobel) persona
echo "Fixing Blemo category..."
blemo_file=$(grep -Rl '^name:[[:space:]]*Blemo$' canonical/factions/*.yaml)
if [[ -n "$blemo_file" ]]; then
  echo " - Editing $blemo_file"
  sed -i 's/^category:[[:space:]]*factions/category: characters/' "$blemo_file"
  mv "$blemo_file" canonical/characters/
else
  echo " - Blemo YAML not found in canonical/factions"
fi

# 3) Create new UUID and YAML for Eries (Decay persona)
echo "Adding Eries (Decay persona)..."
eries_uuid=$(uuidgen)
eries_file="canonical/characters/${eries_uuid}.yaml"
if [[ ! -f "$eries_file" ]]; then
  cat > "$eries_file" <<EOF
id: ${eries_uuid}
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
EOF
  echo " - Created $eries_file"
else
  echo " - $eries_file already exists"
fi

# 4) Update Core and Dossiers with Eries.md and Eries_Dossier.md stubs
echo "Adding Core and dossier entries for Eries..."
core_dir="Characters/Core"
dossier_dir="character_dossiers"

if [[ ! -f "$core_dir/Eries.md" ]]; then
  cat > "${core_dir}/Eries.md" <<EOF
Eries
=====

tags: character/godpersona aliases: [The Harbinger of Decay] principle: "[[Decay]]" faction: "Independent" status: "Active"

| **Principle** | [[Decay]] (Seeri) |
|---------------|-------------------|
| **Mortal Mask** | A champion of necessary endings, Eries believes that entropy is the crucible of new life. |

Overview
--------

Eries embodies the principle of Decay, unleashing entropy to reset what has grown too rigid or broken.
EOF
  echo " - Created $core_dir/Eries.md"
else
  echo " - Core character Eries.md already exists"
fi

if [[ ! -f "$dossier_dir/Eries_Dossier.md" ]]; then
  cat > "${dossier_dir}/Eries_Dossier.md" <<EOF
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
EOF
  echo " - Created $dossier_dir/Eries_Dossier.md"
else
  echo " - Dossier Eries_Dossier.md already exists"
fi

echo "All updates complete. Commit your changes:"
echo "  git add canonical/characters canonical/factions Characters/Core character_dossiers"
echo "  git commit -m \"Fix god-persona names: Corlexi, add Eries, unify categories\""
echo "  git push"
