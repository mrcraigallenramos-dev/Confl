---
tags: ['document']
---

# Confluence Chronicles Story Bible Repository

This repository contains the story bibles for the Confluence Chronicles project, parsed into a canonical, schema-validated format.

## Directory Layout:

- `canonical/`: Contains schema-validated YAML files for extracted entities (characters, locations, factions, magic, events, scenes).
- `source/`: Original markdown story bible files.
- `schema/`: JSON Schema definitions for entity validation.
- `scripts/`: Python scripts for ingestion, validation, and other utilities.
- `tools/`: Placeholder for any external tools or configurations.
- `logs/`: Log files generated during ingestion and processing.
- `provenance_index.json`: Maps entity IDs to their source locations in the original story bibles.
- `ingest_log.txt`: Log of the ingestion process.

