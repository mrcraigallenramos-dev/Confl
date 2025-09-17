
import argparse
import os
import yaml
import json
from jsonschema import validate, ValidationError

def validate_yaml_file(yaml_file_path, schema):
    with open(yaml_file_path, 'r') as f:
        yaml_data = yaml.safe_load(f)
    try:
        validate(instance=yaml_data, schema=schema)
        return True, None
    except ValidationError as e:
        return False, e

def main():
    parser = argparse.ArgumentParser(description="Validate YAML files against a JSON schema.")
    parser.add_argument("yaml_dir", help="Directory containing YAML files to validate.")
    parser.add_argument("schema_file", help="Path to the JSON schema file.")
    args = parser.parse_args()

    with open(args.schema_file, 'r') as f:
        schema = json.load(f)

    log_file_path = os.path.join(os.path.dirname(os.path.dirname(args.yaml_dir)), 'logs', 'validation_log.txt')
    os.makedirs(os.path.dirname(log_file_path), exist_ok=True)

    total_files = 0
    valid_files = 0
    invalid_files = []

    with open(log_file_path, 'w') as log_file:
        log_file.write(f"Validation started for YAML files in {args.yaml_dir} against {args.schema_file}\n")
        for root, _, files in os.walk(args.yaml_dir):
            for file in files:
                if file.endswith(('.yaml', '.yml')):
                    total_files += 1
                    yaml_file_path = os.path.join(root, file)
                    is_valid, error = validate_yaml_file(yaml_file_path, schema)
                    if is_valid:
                        valid_files += 1
                        log_file.write(f"  {yaml_file_path}: VALID\n")
                    else:
                        invalid_files.append((yaml_file_path, error))
                        log_file.write(f"  {yaml_file_path}: INVALID - {error.message}\n")
        
        log_file.write(f"\nValidation completed.\n")
        log_file.write(f"Total files: {total_files}\n")
        log_file.write(f"Valid files: {valid_files}\n")
        log_file.write(f"Invalid files: {len(invalid_files)}\n")
        if invalid_files:
            log_file.write("Details of invalid files:\n")
            for file_path, error in invalid_files:
                log_file.write(f"  - {yaml_file_path}: {error.message}\n")

    print(f"Validation completed. See {log_file_path} for details.")
    if invalid_files:
        print("Validation failed for some files.")
        exit(1)
    else:
        print("All YAML files are valid.")
        exit(0)

if __name__ == '__main__':
    main()


