#!/usr/bin/env python3
import os

VAULT_DIR = '/home/ubuntu/upload/obsidian_vault'
FILE_LIST = os.path.join(VAULT_DIR, 'file_list.txt')
INDEX_FILE = os.path.join(VAULT_DIR, '_index.md')

def get_file_tags(full_path):
    try:
        with open(full_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except UnicodeDecodeError:
        try:
            with open(full_path, 'r', encoding='latin-1') as f:
                content = f.read()
        except Exception:
            return []

    tags = []
    if content.startswith('---\n'):
        front_matter_end = content.find('---\n', 4)
        if front_matter_end != -1:
            front_matter = content[4:front_matter_end]
            for line in front_matter.split('\n'):
                if line.strip().startswith('tags:'):
                    tag_str = line.split('tags:')[1].strip()
                    tag_list = [t.strip().replace("'", "") for t in tag_str.strip("[]").split(",") if t.strip()]
                    tags.extend(tag_list)
    return tags

def main():
    with open(FILE_LIST, 'r') as f:
        files = [line.strip() for line in f]

    with open(INDEX_FILE, 'w') as f:
        f.write("# Vault Index\n\n")
        for file_path in sorted(files):
            full_path = os.path.join(VAULT_DIR, file_path)
            if os.path.isfile(full_path):
                tags = get_file_tags(full_path)
                tag_str = ", ".join(tags)
                f.write(f"- [[{file_path}]]\n  - Tags: {tag_str}\n")

if __name__ == '__main__':
    main()


