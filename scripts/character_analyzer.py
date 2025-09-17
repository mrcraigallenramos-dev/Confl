
import argparse
import os
import yaml
import json
import re

def analyze_character(character_data):
    analysis = {
        "id": character_data["id"],
        "name": character_data["name"],
        "category": character_data["category"],
        "description": character_data["description"],
        "identity_score": 0,
        "wound_score": 0,
        "journey_score": 0,
        "pivotal_moments_score": 0,
        "underdeveloped_areas": []
    }

    description = character_data["description"].lower()

    # Identity Analysis
    # Look for explicit statements about who they are, their worldview, etc.
    identity_keywords = ["is a", "are a", "believes", "worldview", "identity"]
    if any(keyword in description for keyword in identity_keywords):
        analysis["identity_score"] += 1
    if len(description.split()) > 10: # Longer descriptions might imply more identity info
        analysis["identity_score"] += 1
    if analysis["identity_score"] < 2:
        analysis["underdeveloped_areas"].append("Identity")

    # Wound Analysis
    # Look for mentions of trauma, negative events, fears, motivations driven by past
    wound_keywords = ["trauma", "wound", "fear", "motivation", "past", "betrayal", "suffering", "punish"]
    if any(keyword in description for keyword in wound_keywords):
        analysis["wound_score"] += 1
    if analysis["wound_score"] == 0:
        analysis["underdeveloped_areas"].append("Wound")

    # Journey Analysis (emotional arc, change, overcoming obstacles)
    journey_keywords = ["arc", "journey", "change", "overcome", "obstacle", "evolve"]
    if any(keyword in description for keyword in journey_keywords):
        analysis["journey_score"] += 1
    if analysis["journey_score"] == 0:
        analysis["underdeveloped_areas"].append("Journey")

    # Pivotal Moments Analysis (specific scenes, events that define them)
    pivotal_keywords = ["scene", "moment", "event", "tested", "revealed", "defining"]
    if any(keyword in description for keyword in pivotal_keywords):
        analysis["pivotal_moments_score"] += 1
    if analysis["pivotal_moments_score"] == 0:
        analysis["underdeveloped_areas"].append("Pivotal Moments")

    return analysis

def main():
    parser = argparse.ArgumentParser(description="Analyze character YAML files for depth.")
    parser.add_argument("canonical_dir", help="Directory containing canonical YAML files.")
    parser.add_argument("output_report", help="Path to the output Character Insight Report JSON file.")
    args = parser.parse_args()

    character_analyses = []
    character_files = []

    # Collect all character YAML files
    for root, _, files in os.walk(os.path.join(args.canonical_dir, "characters")):
        for file in files:
            if file.endswith((".yaml", ".yml")):
                character_files.append(os.path.join(root, file))
    
    # If no character files found, check misc category for potential characters
    if not character_files:
        for root, _, files in os.walk(os.path.join(args.canonical_dir, "misc")):
            for file in files:
                if file.endswith((".yaml", ".yml")):
                    file_path = os.path.join(root, file)
                    with open(file_path, "r") as f:
                        entity_data = yaml.safe_load(f)
                    # Heuristic: if a misc entity has a capitalized name and is not a common word, treat as potential character
                    if entity_data and entity_data.get("name") and entity_data["name"][0].isupper() and len(entity_data["name"].split()) <= 3:
                        # Re-categorize as character for analysis purposes if it seems like one
                        entity_data["category"] = "characters"
                        character_files.append(file_path)

    for file_path in character_files:
        with open(file_path, "r") as f:
            character_data = yaml.safe_load(f)
        if character_data and character_data.get("category") == "characters":
            analysis = analyze_character(character_data)
            character_analyses.append(analysis)

    # Sort characters by how underdeveloped they are (more underdeveloped areas first)
    character_analyses.sort(key=lambda x: len(x["underdeveloped_areas"]), reverse=True)

    report_content = {
        "summary": f"Analyzed {len(character_analyses)} potential characters.",
        "prioritized_characters": []
    }

    for char_analysis in character_analyses:
        report_content["prioritized_characters"].append({
            "name": char_analysis["name"],
            "id": char_analysis["id"],
            "description_snippet": char_analysis["description"][:150] + "..." if len(char_analysis["description"]) > 150 else char_analysis["description"],
            "underdeveloped_areas": char_analysis["underdeveloped_areas"],
            "scores": {
                "identity": char_analysis["identity_score"],
                "wound": char_analysis["wound_score"],
                "journey": char_analysis["journey_score"],
                "pivotal_moments": char_analysis["pivotal_moments_score"]
            }
        })

    with open(args.output_report, "w") as f:
        json.dump(report_content, f, indent=2)

    print(f"Character Insight Report generated at {args.output_report}")

if __name__ == "__main__":
    main()


