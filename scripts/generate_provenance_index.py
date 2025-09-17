
import os
import json
import yaml
import argparse

def generate_provenance_index(canonical_dir, output_file):
    provenance_index = {}
    for root, _, files in os.walk(canonical_dir):
        for file in files:
            if file.endswith((".yaml", ".yml")):
                file_path = os.path.join(root, file)
                with open(file_path, "r") as f:
                    entity_data = yaml.safe_load(f)
                
                entity_id = entity_data.get("id")
                if entity_id:
                    provenance_index[entity_id] = entity_data.get("source", {})
    
    with open(output_file, "w") as f:
        json.dump(provenance_index, f, indent=2)

def main():
    parser = argparse.ArgumentParser(description="Generate a provenance index from canonical YAML files.")
    parser.add_argument("canonical_dir", help="Directory containing canonical YAML files.")
    parser.add_argument("output_file", help="Path to the output provenance index JSON file.")
    args = parser.parse_args()

    generate_provenance_index(args.canonical_dir, args.output_file)
    print(f"Provenance index generated at {args.output_file}")

if __name__ == "__main__":
    main()


