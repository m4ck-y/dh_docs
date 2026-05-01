# Data Dictionary: document_type_config

**Context**: `expedient`
**Type**: `Database Model`
**Storage**: MongoDB
**Model File**: `infrastructure/database/models/document_type_config.py`

## Overview

> Configuración de validación de tipos de documento. Mapea a las tablas PostgreSQL `document_category` y `document_type`. Fuente de verdad para categorías y subtypes: PostgreSQL.

## Fields

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | ObjectId | PK, NOT NULL | Primary key |
| `category_name` | string | NOT NULL, INDEX | Nombre de categoría (de `document_category.name`) |
| `subtype_name` | string | NOT NULL | Nombre del tipo (de `document_type.name`) |
| `name` | string | NOT NULL | Nombre para display: "INE - Identificación Oficial" |
| `extensions` | list[string] | NOT NULL | Extensiones habilitadas: `["pdf", "jpg", "png"]` |
| `max_size_bytes` | int | NOT NULL | Tamaño máximo en bytes |
| `required` | bool | NOT NULL, DEFAULT false | Obligatorio en onboarding |
| `active` | bool | NOT NULL, DEFAULT true | Habilitado/deshabilitado |

## Business Rules

1. La combinación `(category_name, subtype_name)` debe existir en PostgreSQL.
2. Si `required=true`, el usuario no puede completar onboarding sin subir documento de este tipo.
3. Solo un tipo por categoría puede estar marcado como `required`.
4. Los valores se leen dinámicamente de PostgreSQL.

## Relationships

- `category_name` → `document_category.name` (PostgreSQL)
- `subtype_name` → `document_type.name` (PostgreSQL)

## JSON Example

```json
{
  "id": "64f1a2b3c4d5e6f7a8b9c0d1",
  "category_name": "Identificación",
  "subtype_name": "INE",
  "name": "INE - Identificación Oficial",
  "extensions": ["pdf", "jpg", "png"],
  "max_size_bytes": 10485760,
  "required": true,
  "active": true
}
```