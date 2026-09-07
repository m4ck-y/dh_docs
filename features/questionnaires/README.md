# Catálogo de cuestionarios — ERD de definición

Diagrama físico (persistencia) del **catálogo de cuestionarios**, cubriendo solo la
**definición** del instrumento (preguntas, opciones, condiciones, scoring y
metadatos). Las respuestas y la asignación (`assignment`/`scheduled`/`response`/`answer`)
se modelan en un diagrama aparte.

## Fuente

- `other_projects/app_questionnaire/backend/docs/db_ddl.sql` — tablas `form` y
  `question` como base.
- Contrato del motor frontend: `docs/diagrams/schemas/cuestionario/README.md`.
- Reglas de formato: `.agents/rules/DOCUMENTATION_ERD.md` y
  `.agents/rules/MERMAID_ENUM_REPRESENTATION.md`.

## Archivos

| Archivo | Contenido |
|---|---|
| `erd-catalogo.mmd` | ERD Mermaid `erDiagram` con entidades, enums y relaciones. |
| `db_ddl.sql` | Copia de referencia del DDL de `app_questionnaire` (tablas `form`/`question` de definición + `assignment`/`scheduled`/`response`/`answer` de ejecución). |

## Decisiones de adaptación a `dh_`

1. **`form` → `questionnaire`**, `question` → `questionnaire_item` (nombres `dh_`,
   schema PostgreSQL propuesto `catalog`).
2. **`questionnaire_item` recursivo** (`parent_item_id`): unifica secciones
   (`list_sections`) y preguntas en una sola entidad, alineado con FHIR
   `Questionnaire.item`. Elimina el gap de `list_sections`.
3. **Opciones tipadas** en tabla propia (`questionnaire_option`) en lugar del
   `config JSONB` genérico de la DDL.
4. **Condiciones de visibilidad** (`questionnaire_condition`) como entidad,
   siguiendo el Anexo C/D de `docs/diagrams/` y el `conditional` de la referencia.
5. **`scoring_expression` / `evaluation_expression`** permanecen `JSONB` (AST,
   fiel a la DDL) en lugar de `interpretacion[]` de TypeScript; así caben scoring
   no lineales (IPAQ/METs) y subescalas.
6. **`verified`** (inmutabilidad) se conserva de la DDL como pilar del catálogo.
7. **Columnas heredadas de `BaseModel`** (`id`, `uuid`, `created_at`,
   `updated_at`, `deleted_at`, `*_by_id_user`) se omiten del diagrama por
   convención (`PYTHON_INFRA_DB_BASE_MODEL.md`).

## Gaps del documento `catalog-questionnaires.md` cubiertos aquí

| Gap | Resolución |
|---|---|
| `list_sections` | `questionnaire_item` tipo `GROUP` con `parent_item_id`. |
| `target_sex` | Columna `target_sex` de `questionnaire`. |
| `list_references` | Entidad `reference` (1:N). |
| `list_categories` / `list_cie11_codes` | N:N puras (`questionnaire_categories`, `questionnaire_cie11_codes`). |
| `list_evaluation_topics` | Entidad `evaluation_topic` (1:N). |

## Pendientes (no bloquean este ERD)

- Resolver PHQ-9 ítem 7 (contenido, no schema).
- Decidir forma canónica de scoring (JSONB/AST vs `interpretacion[]`).
- Modelar respuestas + asignación (siguiente diagrama).
- Confirmar el nombre del schema PostgreSQL (`catalog` propuesto; requiere
  añadirlo a `ALL_SCHEMAS` en `dh_shared/base.py`).
