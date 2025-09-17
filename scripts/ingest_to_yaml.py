
import argparse
import os
import re
import yaml
import uuid
import spacy

# Load spaCy model outside the function for efficiency
try:
    nlp = spacy.load("en_core_web_sm")
except OSError:
    print("Downloading spaCy model \'en_core_web_sm\'...")
    spacy.cli.download("en_core_web_sm")
    nlp = spacy.load("en_core_web_sm")

def chunk_text(text, chunk_size=600):
    chunks = []
    current_chunk = []
    current_length = 0

    paragraphs = text.split("\n\n")

    for para in paragraphs:
        para_length = len(para.split())
        if current_length + para_length <= chunk_size:
            current_chunk.append(para)
            current_length += para_length
        else:
            if current_chunk:
                chunks.append("\n\n".join(current_chunk))
            current_chunk = [para]
            current_length = para_length
    if current_chunk:
        chunks.append("\n\n".join(current_chunk))
    return chunks

def extract_entities(text, source_file, line_start, line_end, source_tag):
    entities = []
    doc = nlp(text)

    # Collect all potential entities from spaCy
    potential_entities = []
    for ent in doc.ents:
        potential_entities.append((ent.text, ent.label_, ent.start_char, ent.end_char))
    
    # Also consider capitalized words that might be names but not caught by spaCy as PERSON
    capitalized_words = re.finditer(r'\b[A-Z][a-zA-Z\-\\]+(?:\s[A-Z][a-zA-Z\-\\]+)*\b', text)
    for match in capitalized_words:
        word = match.group(0)
        start_char = match.start()
        end_char = match.end()
        if not any(pe_text == word and pe_start == start_char for pe_text, pe_label, pe_start, pe_end in potential_entities):
            potential_entities.append((word, "MISC", start_char, end_char))

    # Filter out common words and phrases that are not entities
    common_words = {"The", "And", "But", "Or", "A", "An", "In", "On", "With", "For", "From", "By", "To", "Of", "Is", "Are", "Was", "Were", "It", "This", "My", "Knowledge", "Having", "Once", "Should", "Do", "Continue", "Summarize", "Analyze", "Could", "Generate", "Extract", "Reading", "Executing", "Accessing", "Understanding", "Viewing", "Thinking", "Creating", "Editing", "Skip", "Try", "Manus", "Computer", "Editor", "Replay", "GitHub", "Confl", "Novella", "Divine", "Masks", "Factions", "Practices", "Iconography", "Rituals", "Mortal", "Mask", "Purity", "Form", "Wholeness", "Bell", "Glass", "Mothers", "Choir", "Weavers", "Cantors", "Line", "Masons", "Stoneseers", "Cantor", "Retaliation", "Teams", "Flensers", "White", "Mercy", "Collectors", "Dust", "Mercy", "Kitchens", "Unseen", "Architects", "Kitewrights", "Timekeepers", "Brasshaven", "Soulpulse", "Lanterns", "mrcraigallenramos-dev/", "TheConfluenceChronicles_RevisedStoryBible-AMasterclassinStrategicStorytelling.md"}

    for ent_text, ent_label, ent_start_char, ent_end_char in set(potential_entities):
        if len(ent_text) > 1 and ent_text not in common_words and not ent_text.startswith("http") and not ent_text.endswith(".md") and not ent_text.endswith(".py") and not ent_text.endswith(".txt") and not ent_text.endswith(".yaml") and not ent_text.endswith(".json") and not ent_text.endswith(".sh") and not ent_text.endswith("/"):
            category = "misc"
            description = "" # Initialize description

            # Find the most relevant sentence or paragraph for the entity
            best_description_found = False
            for sent in doc.sents:
                if ent_text in sent.text:
                    description = sent.text.strip()
                    best_description_found = True
                    break
            
            if not best_description_found:
                # If no specific sentence, try to get the paragraph
                paragraphs = text.split("\n\n")
                for para in paragraphs:
                    if ent_text in para:
                        description = para.strip()
                        break

            # More robust categorization based on entity type and context
            if ent_label == "PERSON" or ent_text in ["Luthen", "Mobel", "Corlex", "Salee", "Alara", "Quinlan", "Jhace", "Tiffani"]:
                category = "characters"
            elif ent_label in ["ORG", "NORP", "FAC"] or ent_text in ["Cadence", "Blemo", "Xilcore", "Leesa", "Unseen Architects", "Kitewrights", "Timekeepers", "Sanitists", "White-Gloves", "Flensers of White Mercy", "Collectors of Dust", "Mercy Kitchens", "Crystalline Orthodoxy", "Cantors of Axiom", "Line Masons", "Stoneseers", "Cantor Retaliation Teams", "Unifieds", "Glass Mothers", "Choir Weavers"]:
                category = "factions"
            elif ent_label in ["GPE", "LOC"] or ent_text == "Brasshaven":
                category = "locations"
            elif ent_label == "EVENT":
                category = "events"
            elif ent_text == "Soulpulse Lanterns":
                category = "magic"

            entity_id = str(uuid.uuid4())
            entities.append({
                "id": entity_id,
                "name": ent_text,
                "category": category,
                "description": description, 
                "source": {
                    "file": source_file,
                    "section_heading": "", # This would require more advanced parsing
                    "line_start": line_start,
                    "line_end": line_end,
                    "tag": source_tag
                }
            })
    return entities

def main():
    parser = argparse.ArgumentParser(description="Ingest markdown story bibles into YAML entities.")
    parser.add_argument("--input", required=True, help="Input markdown file(s) path (e.g., /path/to/*.md)")
    parser.add_argument("--out", required=True, help="Output directory for YAML files (e.g., canonical/)")
    parser.add_argument("--chunk_size", type=int, default=600, help="Size of text chunks for entity extraction.")
    parser.add_argument("--source_tag", default="uploaded_bibles", help="Tag for the source of the ingested data.")
    args = parser.parse_args()

    log_file_path = os.path.join(os.path.dirname(os.path.dirname(args.out)), "logs", "ingest_log.txt")
    os.makedirs(os.path.dirname(log_file_path), exist_ok=True)
    
    with open(log_file_path, "w") as log_file:
        log_file.write(f"Ingestion started at {os.path.basename(args.input)} with chunk size {args.chunk_size} and source tag {args.source_tag}\n")

        input_files = []
        if "*" in args.input:
            import glob
            input_files = glob.glob(args.input)
        else:
            input_files = [args.input]

        for input_file in input_files:
            log_file.write(f"Processing file: {input_file}\n")
            with open(input_file, "r") as f:
                content = f.read()
            
            lines = content.splitlines()
            line_num = 0
            
            chunks = chunk_text(content, args.chunk_size)
            
            for i, chunk in enumerate(chunks):
                # Approximate line numbers for the chunk
                chunk_line_start = content.find(chunk) + 1
                chunk_line_end = chunk_line_start + chunk.count("\n")

                entities = extract_entities(chunk, os.path.basename(input_file), chunk_line_start, chunk_line_end, args.source_tag)
                for entity in entities:
                    output_dir = os.path.join(args.out, entity["category"])
                    os.makedirs(output_dir, exist_ok=True)
                    output_path = os.path.join(output_dir, f'{entity["id"]}.yaml')
                    with open(output_path, "w") as outfile:
                        yaml.dump(entity, outfile, sort_keys=False)
                    log_file.write(f'  Extracted {entity["category"]}: {entity["name"]} to {output_path}\n')
        log_file.write("Ingestion completed.\n")

if __name__ == "__main__":
    main()


