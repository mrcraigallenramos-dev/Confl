#!/usr/bin/env python3
import os

VAULT_DIR = '/home/ubuntu/upload/obsidian_vault'
UNTAGGED_FILES = os.path.join(VAULT_DIR, 'untagged_files.txt')

def get_tags_from_path(file_path):
    relative_path = file_path.lstrip('./')
    name_without_ext = os.path.splitext(relative_path)[0]
    parts = name_without_ext.split(os.sep)
    tags = []
    if len(parts) > 1:
        for part in parts[:-1]:
            if part.lower() not in ['canonical', 'source', 'chapters', 'novella_beats', 'series_1_echoes_of_the_god_shock_-_the_setup', 'series_2_chains_of_the_gearlords_-_the_pawn_sacrifice']:
                tags.append(part.replace(' ', '_').replace('-', '_').lower())
    filename_tag = parts[-1].replace(' ', '_').replace('-', '_').lower()
    if filename_tag and filename_tag not in ['index', 'readme', 'blueprint', 'chapter']:
        tags.append(filename_tag)
    if not tags:
        tags.append('document')
    return sorted(list(set(tags)))

def add_tags_to_file(full_path, tags):
    try:
        with open(full_path, 'r+', encoding='utf-8') as f:
            content = f.read()
            f.seek(0)
            if content.startswith('---\n') and '---' in content[4:]:
                front_matter_end = content.find('---', 4) + 3
                front_matter = content[:front_matter_end]
                body = content[front_matter_end:]
                if 'tags:' in front_matter or 'tag:' in front_matter:
                    return
                else:
                    new_front_matter = front_matter.strip() + f"\ntags: {tags}\n---\n"
                    f.write(new_front_matter + body)
            else:
                f.write(f"---\ntags: {tags}\n---\n\n" + content)
    except UnicodeDecodeError:
        try:
            with open(full_path, 'r+', encoding='latin-1') as f:
                content = f.read()
                f.seek(0)
                if content.startswith('---\n') and '---' in content[4:]:
                    front_matter_end = content.find('---', 4) + 3
                    front_matter = content[:front_matter_end]
                    body = content[front_matter_end:]
                    if 'tags:' in front_matter or 'tag:' in front_matter:
                        return
                    else:
                        new_front_matter = front_matter.strip() + f"\ntags: {tags}\n---\n"
                        f.write(new_front_matter + body)
                else:
                    f.write(f"---\ntags: {tags}\n---\n\n" + content)
        except Exception as e:
            print(f"Error processing {full_path} with latin-1: {e}")
    except Exception as e:
        print(f"Error processing {full_path}: {e}")

def main():
    with open(UNTAGGED_FILES, 'r') as f:
        untagged_files = [line.strip() for line in f]
    for file_path in untagged_files:
        full_path = os.path.join(VAULT_DIR, file_path)
        if os.path.isfile(full_path):
            tags = get_tags_from_path(file_path)
            add_tags_to_file(full_path, tags)
            print(f"Added tags {tags} to {file_path}")

if __name__ == '__main__':
    main()


