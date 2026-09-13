# Catálogo de cuestionarios — modelo de datos

Módulo del **catálogo de cuestionarios**. Cubre dos capas:

1. **Definición** del instrumento (`form`, `question`, metadata, scoring).
2. **Ejecución** (asignación y respuestas: `assignment`, `scheduled`, `answer`).

**Estado:** En definición (pendiente).

## Fuente de verdad

- **`schema.sql`** — copia de referencia del DDL de
  `other_projects/app_questionnaire/backend/docs/db_ddl.sql`. Es la **única
  fuente de verdad/legacy** del modelo:
  - Definición: `form` (con `scoring_expression`, `evaluation_expression`,
    `verified`) y `question` (con `key`, `type`/`EQuestionType`, `order`).
  - Ejecución: `assignment` (tarea/evento), `scheduled` (0..1 opcional), `answer`.
- Reglas de formato: `.agents/rules/DOCUMENTATION_ERD.md` y
  `.agents/rules/MERMAID_ENUM_REPRESENTATION.md`.
- Referencia (no fuente de verdad): contrato del motor frontend en
  `docs/diagrams/schemas/cuestionario/README.md`.

## Capas

| Capa | Carpeta | Contenido |
|---|---|---|
| Catálogo / Definición | [`catalog/`](./catalog/) | Comparativa de 4 fuentes, matriz de concordancia, ERD y diagrama de clases del instrumento. |
| Ejecución / Respuestas (V2) | [`responses/`](./responses/) | Modelo V2 (`assignment` como tarea/evento), cardinalidades y diferencias V1 → V2. |

## Decisiones tomadas en el modelo

| Tema | Decisión | Reflejo en el DDL |
|---|---|---|
| Opciones de respuesta | Tabla propia `option` | ✅ `option` (+ `url` asociada) |
| Condicional | Fórmula libre en tabla propia | ✅ `conditional_logic` |
| Agrupación | `section` + tablas puente | ✅ `section`, `questions_form`, `questions_section` |
| Tipo de pregunta | Enum tipado | ✅ Columna `"type"` de tipo `EQuestionType` |
| Config por tipo | No aplica; opciones y condiciones en tablas | ✅ Se eliminó `question.config` |
| Metadatos | Tablas normalizadas | ✅ `category`, `cie11_code`, `evaluation_topic`, `reference`, `estimated_duration`, `age_group`, `target_sex`, `population` + puentes |
| Schema PostgreSQL | `form` | ✅ Documentado en comentarios del DDL (`-- Schema: form`); aún no se ejecuta `CREATE SCHEMA form` |
| Campos de auditoria | Heredados de `BaseModel` en Python | ✅ Documentado en comentarios del DDL (`uuid`, `created_at`, `updated_at`, `deleted_at`, `*_by_id_user`); el ORM los agrega |
| Diagrama de documentos | `CLASS.mmd` (vista MongoDB) por capa | No aplica (vista no relacional) |

## Decisiones abiertas

- Confirmar el nombre del schema PostgreSQL (`form` propuesto) y añadirlo a
  `ALL_SCHEMAS` (`dh_shared/base.py`).

## Convención de nombres

- **`catalog/`** y **`responses/`**: carpetas de capa (en inglés).
- **`ERD.mmd`**: diagrama entidad-relación de la capa.
- **`CLASS.mmd`**: diagrama de clases / vista de documentos de la capa.
- **`example.jsonc`**: ejemplo de payload de la capa.
  - Extensión `.jsonc` porque incluye comentarios `/* */`.
  - Si un ejemplo no necesita comentarios, puede usarse `.json`.
- **`schema.sql`**: DDL consolidado del módulo, en la raíz.

## Archivos

```
questionnaires/
├── README.md            # Este índice (estado, decisiones, pendientes)
├── schema.sql           # Fuente de verdad: DDL de definición + ejecución
├── catalog/             # Capa catálogo / definición
│   ├── README.md
│   ├── ERD.mmd
│   ├── CLASS.mmd
│   └── example.jsonc
└── responses/           # Capa ejecución / respuestas (V2)
    ├── README.md
    ├── ERD.mmd
    ├── CLASS.mmd
    └── example.jsonc
```

## Pendientes

- Resolver PHQ-9 ítem 7 (contenido, no schema) — ver [`catalog/README.md`](./catalog/README.md).
- Confirmar el nombre del schema PostgreSQL y añadirlo a `ALL_SCHEMAS`
  (`dh_shared/base.py`).
- Verificar que `schema.sql` no conserve remanentes del modelo V1
  (`form_direct_responses` / `scheduled_responses`).
