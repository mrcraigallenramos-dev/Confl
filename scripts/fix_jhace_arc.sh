#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="06_Outlines/Series_1/Novella_1"

declare -A FILE_CONTENTS=(
    [S1N1_CH01.md]=$'---\nseries: 1\nnovella: 1\nfile: S1N1_CH01\ntype: chapter\npov: Jhace\nsetting: Grindheim Dregs — pump room and lanes\nword_target_min: 1201\nword_target_max: 2299\nstatus: outline\n---\n# Quieting the Failing Pump\n\n**Logline:** Jhace quiets a failing pump with a Wholeness Knot as Tiffani calms a distressed crowd, both paying small costs while masking a natural pull with grit and banter.\n\n## Beat Breakdown\n- Open on gearpunk texture: turbines grinding, pipes ticking like nerves.\n- The pump coughs in desperation until Jhace soothes it with a breath-long Wholeness Knot; he absorbs a searing headache.\n- Tiffani uses a Form whisper to calm the crowd, steadying nerves with crystalline focus.\n- They banter over ledger stamps and numerical errors, chemistry sparking subtly without naming it romance.\n- A worker marks their names in gratitude, foreshadowing cultural tethers.\n- Jhace fingers a flawed gear in his pocket; Tiffani notices and makes a mental note.\n'
    [S1N1_CH02.md]=$'---\nseries: 1\nnovella: 1\nfile: S1N1_CH02\ntype: chapter\npov: Jhace\nsetting: Salvage lane, then Foundry Fire memory\nword_target_min: 1201\nword_target_max: 2299\nstatus: outline\n---\n# The Foundry Fire and Luthen’s Lesson\n\n**Logline:** Jhace recalls the Foundry Fire and Master Luthen’s teaching—that strength comes from small imperfections—while Tiffani tends to his brittle wrists with sympathetic care.\n\n## Beat Breakdown\n- Salvage sparks flashbacks: red heat, snapping struts, screaming ceilings.\n- Master Luthen teaches the “shining cage” lesson: imperfection allows systems to bend and survive.\n- The flawed gear becomes a talisman and worldview symbol.\n- Tiffani soothes Jhace’s wrists with targeted resonance, feeling his tremors as a shared burden.\n- Their relationship deepens through this quiet tenderness and mutual healing.\n'
    # Add more chapters as needed here...
)

for FILE in "${!FILE_CONTENTS[@]}"; do
    TARGET="$BASE_DIR/$FILE"
    echo "Updating $TARGET"
    printf "%s\n" "${FILE_CONTENTS[$FILE]}" > "$TARGET"
done

echo "Jhace arc updates applied to Series 1 Novella 1. Review, commit, and push."
