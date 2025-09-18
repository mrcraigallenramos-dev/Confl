# Confluence Chronicles Story Bible Repository

A comprehensive, schema-validated repository containing the canonical story bible for **The Confluence Chronicles** saga, organized into structured data formats for consistency and cross-reference validation.

## 🏗️ Repository Structure

### Core Directories

- **`canonical/`** - Schema-validated YAML entities extracted from source materials
- **`Characters/`** - Detailed markdown character profiles organized by importance
- **`character_dossiers/`** - Comprehensive psychological profiles for key characters
- **`schema/`** - JSON Schema definitions for entity validation
- **`scripts/`** - Python utilities for ingestion, validation, and processing
- **`source/`** - Original markdown story bible files
- **`logs/`** - Processing and ingestion logs
- **`provenance_index.json`** - Maps entity IDs to source locations

## 🎭 The Four Divine Personas

The gods of this universe walk among mortals using **anagrammed identities**:

| **Divine Name** | **Principle** | **Mortal Persona** | **Canonical ID** |
|-----------------|---------------|-------------------|------------------|
| **Xilcore** | Form | **Corlexi** | `18e96714-953e-457e-a18a-c93585a9bb10` |
| **Blemo** | Purity | **Mobel** | `1fb39ffc-7c60-4bcc-8282-f2b567c9c36d` |
| **Leesa** | Wholeness | **Salee** | `30a53c18-f1b3-4774-8ace-d0440716baef` |
| **Seeri** | Decay | **Eries** | *[Generated UUID]* |

Each mortal persona embodies their divine principle's traits while maintaining the deception of mortality.

## 📊 Character System Architecture

### Three-Tier Character Organization

1. **`canonical/characters/`** - UUID-based YAML entities with structured metadata
2. **`Characters/Core/`** - Rich markdown profiles with psychological depth
3. **`character_dossiers/`** - Comprehensive biographical and arc information

### Core Characters

- **Jhace** - Wholeness resonant, protagonist, unwitting cosmic weapon
- **Tiffani** - Form resonant (disguised), the Counter-Spark manipulator
- **Ember (The Null Child)** - Void entity, paradoxical innocence
- **Calix, Vael, Lysandra Vane, Alara, Brighlee, Toren** - Supporting cast

## 🔧 Entity Schema Validation

All canonical entities conform to `schema/entity_schema.json`:


## 🚀 Usage & Validation

### Running Validation

### Adding New Entities
1. Create YAML in appropriate `canonical/` subfolder
2. Update `provenance_index.json` with source mapping
3. Add corresponding entries in `Characters/` and `character_dossiers/` if applicable
4. Run validation to ensure schema compliance

## 📈 Recent Updates

- ✅ **Unified god personas**: Corrected Corlex→Corlexi, added missing Eries
- ✅ **Category standardization**: Moved character entities from factions to characters
- ✅ **YAML cleanup**: Fixed escape sequences and formatting artifacts  
- ✅ **Consistency validation**: All three character systems now aligned
- ✅ **Garbage removal**: Eliminated malformed and placeholder entities

## 🎯 Quality Assurance

This repository maintains consistency through:
- JSON Schema validation for all canonical entities
- Cross-system character verification (canonical ↔ Core ↔ dossiers)
- Provenance tracking to source materials
- Automated formatting and whitespace cleanup
- Anagram validation for divine personas

## 📝 Contributing

When adding new content:
1. Follow the established naming conventions
2. Validate against schemas before committing
3. Maintain cross-references between character systems
4. Update provenance tracking for source attribution

---

**The Confluence Chronicles** - Where gods argue through mortals, and the friction of their eternal conflict powers the universe itself.
