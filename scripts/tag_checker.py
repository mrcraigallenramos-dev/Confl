#!/usr/bin/env python3
import os

VAULT_DIR = '/home/ubuntu/upload/obsidian_vault'
FILE_LIST = os.path.join(VAULT_DIR, 'file_list.txt')
UNTAGGED_FILES = os.path.join(VAULT_DIR, 'untagged_files.txt')

def main():
    untagged = []
    with open(FILE_LIST, 'r') as f:
        files = [line.strip() for line in f]

    for file_path in files:
        full_path = os.path.join(VAULT_DIR, file_path)
        if not os.path.exists(full_path):
            print(f"File not found: {full_path}")
            continue

        try:
            with open(full_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except UnicodeDecodeError:
            try:
                with open(full_path, 'r', encoding='latin-1') as f:
                    content = f.read()
            except Exception as e:
                print(f"Error reading {full_path} with latin-1: {e}")
                continue
        except Exception as e:
            print(f"Error reading {full_path}: {e}")
            continue

        if 'tags:' not in content and 'tag:' not in content:
            untagged.append(file_path)

    with open(UNTAGGED_FILES, 'w') as f:
        for file_path in untagged:
            f.write(f"{file_path}\n")

if __name__ == '__main__':
    main()


