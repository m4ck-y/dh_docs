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
    `verified`) y `question` (con `key`, `type`/`EQuestionType`, `config`).
    El orden de la pregunta vive en las puentes `questions_form` /
    `questions_section` (ver `catalog/README.md` §7). Un formulario se compone
    de preguntas directas **XOR** de secciones (ver ADR 038).
    La forma de `scoring_expression` / `evaluation_expression` se define en
    [`expressions/README.md`](./expressions/README.md).
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
| Lenguaje de expresiones | [`expressions/`](./expressions/) | AST de `scoring_expression` / `evaluation_expression` / `condition`, subescalas y ejemplos. Transversal a definición y ejecución. |

## Decisiones tomadas en el modelo

| Tema | Decisión | Reflejo en el DDL |
|---|---|---|
| Opciones de respuesta | Tabla propia `option` | ✅ `option` (+ `url` asociada) |
| Condicional | AST booleano JSONB en `form.condition` / `section.condition` / `question.condition` (ver ADR 039) | ✅ columnas JSONB |
| Agrupación | `section` + tablas puente; un form usa preguntas directas **XOR** secciones (ver ADR 038) | ✅ `section`, `questions_form`, `questions_section` |
| Tipo de pregunta | Enum tipado | ✅ Columna `"type"` de tipo `EQuestionType` |
| Config por tipo | `config` JSONB en `question`, forma según `type` (ver `catalog/question_types/`) | ✅ `question.config` |
| Scoring / evaluación | **AST de expresiones** (`scoring_expression` + `evaluation_expression`); resultado en `assignment.*_result` como `{value, data_type}` | ✅ JSONB (ver `expressions/`) |
| Orden de pregunta | En la relación: `questions_form.order` / `questions_section.order` (la pregunta es reutilizable) | ✅ `order` en los puentes |
| Metadatos | Tablas normalizadas | ✅ `category`, `cie11_code`, `evaluation_topic`, `reference`, `estimated_duration`, `age_group`, `target_sex`, `population` + puentes |
| Schema PostgreSQL | `form` | ✅ Documentado en comentarios del DDL (`-- Schema: form`); aún no se ejecuta `CREATE SCHEMA form` |
| Campos de auditoria | Heredados de `BaseModel` en Python | ✅ Documentado en comentarios del DDL (`uuid`, `created_at`, `updated_at`, `deleted_at`, `*_by_id_user`); el ORM los agrega |
| Diagrama de documentos | `CLASS.mmd` (vista MongoDB) por capa | No aplica (vista no relacional) |

### Convención de `CLASS.mmd` (vista documentos)

`CLASS.mmd` representa el **modelo documental (MongoDB)** de cada capa:

- **Excluye las entidades/clases puente** (`questions_form`, `questions_section`):
  en un modelo documental la relación se **embebe** dentro del documento padre.
- Consecuencia: el `order` de la pregunta vive en **`Question`** (subdocumento
  embebido con `id`), a diferencia del ERD relacional, donde el orden pertenece
  a la puente.
- `Question` es un **subdocumento** (embebido en `Form` y `Section`), no una
  colección compartida.
- `Form` se compone de `questions` (directas) **XOR** `sections`, nunca ambos
  (ver ADR 038).

## Decisiones abiertas

- Confirmar el nombre del schema PostgreSQL (`form` propuesto) y añadirlo a
  `ALL_SCHEMAS` (`dh_shared/base.py`).

## Convención de nombres

- **`catalog/`** y **`responses/`**: carpetas de capa (en inglés).
- **`ERD.mmd`**: diagrama entidad-relación de la capa.
- **`CLASS.mmd`**: diagrama de clases / vista de documentos (MongoDB) de la capa.
  Excluye clases puente (la relación se embebe); el orden de pregunta vive en
  `Question`.
- **`example.jsonc`**: ejemplo de payload de la capa.
  - Extensión `.jsonc` porque incluye comentarios `/* */`.
  - Si un ejemplo no necesita comentarios, puede usarse `.json`.
- **`question_types/`**: carpeta (en `catalog/`) con un doc por tipo de pregunta;
  documenta la forma de `question.config` según `question.type`.
- **`expressions/`**: gramática del AST (`scoring_expression` /
  `evaluation_expression`) + `examples/` con ejemplos `.jsonc` reutilizables.
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
│   ├── example.jsonc
│   └── question_types/  # Un doc por tipo de pregunta (config por tipo)
├── expressions/         # Lenguaje de expresiones (AST)
│   ├── README.md        # Índice + cadena de evaluación (scoring→result→evaluation→result)
│   ├── operands.md      # Operandos y selectores
│   ├── conditions.md    # Condiciones de visibilidad (form/section/question)
│   ├── factories.md     # Factory functions (referencia)
│   ├── operators/       # Un doc por operador (math, case, aggregate, ...)
│   └── examples/        # Ejemplos .jsonc + casos médicos
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
- Motor frontend: solo soporta `TEXT`, `SINGLE_CHOICE` y `MULTIPLE_CHOICE`
  (`types.ts:1`); falta soporte para el resto de tipos (incluidos `RANGE` y `TIMER`).
