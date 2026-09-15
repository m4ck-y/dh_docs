# Catálogo de cuestionarios — modelo de datos

Módulo del **catálogo de cuestionarios**. Cubre dos capas:

1. **Definición** del instrumento (`form`, `question`, metadata, scoring).
2. **Ejecución** (asignación y respuestas: `assignment`, `scheduled`, `answer`).

**Estado:** En definición (pendiente).

## Fuente de verdad

- **`schema.sql`** — copia de referencia del DDL de
  `other_projects/app_questionnaire/backend/docs/db_ddl.sql`. Es la **única
  fuente de verdad/legacy** del modelo:
  - Definición: `form` (con `expression` y `condition`, `verified`) y `question`
    (con `key`, `type`/`EQuestionType`, `config`, `condition`, `expression`).
    El orden de la pregunta vive en las puentes `questions_form` /
    `questions_section` (ver `catalog/README.md` §7). Un formulario se compone
    de preguntas directas **XOR** de secciones (ver ADR 038).
    La forma del envelope `form.expression` (`scoring`/`evaluation`/`subscales`)
    se define en [`expressions/README.md`](./expressions/README.md).
    `question.expression` define un valor **autocalculado** (solo lectura); su
    resultado se persiste como `answer` con `source = CALCULATED` (ver ADR 041).
  - Ejecución: `assignment` (tarea/evento), `scheduled` (0..1 opcional), `answer`
    (con `source`: `USER` | `CALCULATED`).
- Reglas de formato: `.agents/rules/DOCUMENTATION_ERD.md` y
  `.agents/rules/MERMAID_ENUM_REPRESENTATION.md`.
- Referencia (no fuente de verdad): contrato del motor frontend en
  [`reference/questionnaire-engine.md`](./reference/questionnaire-engine.md).

## Capas

| Capa | Carpeta | Contenido |
|---|---|---|
| Catálogo / Definición | [`catalog/`](./catalog/) | Comparativa de 4 fuentes, matriz de concordancia, ERD y diagrama de clases del instrumento. |
| Ejecución / Respuestas (V2) | [`responses/`](./responses/) | Modelo V2 (`assignment` como tarea/evento), cardinalidades y diferencias V1 → V2. |
| Lenguaje de expresiones | [`expressions/`](./expressions/) | AST del envelope `form.expression` (`scoring`/`evaluation`/`subscales`) y `condition`, con ejemplos. Transversal a definición y ejecución. |
| Banco de datos | [`catalog/bank/`](./catalog/bank/) | Instancias JSON del catálogo (instrumentos e historia clínica) + `categories.json`. |
| Referencia externa | [`reference/`](./reference/) | Contrato del motor frontend (`questionnaire-engine.md`). No es fuente de verdad. |

## Decisiones tomadas en el modelo

| Tema | Decisión | Reflejo en el DDL |
|---|---|---|
| Opciones de respuesta | Tabla propia `option` | ✅ `option` (+ `url` asociada) |
| Condicional | AST booleano JSONB en `form.condition` / `section.condition` / `question.condition` (ver ADR 039) | ✅ columnas JSONB |
| Agrupación | `section` + tablas puente; un form usa preguntas directas **XOR** secciones (ver ADR 038) | ✅ `section`, `questions_form`, `questions_section` |
| Tipo de pregunta | Enum tipado | ✅ Columna `"type"` de tipo `EQuestionType` |
| Config por tipo | `config` JSONB en `question`, forma según `type` (ver `catalog/question_types/`) | ✅ `question.config` |
| Scoring / evaluación | **AST** en `form.expression` (`scoring`/`evaluation`/`subscales`); resultado en `assignment.result` como `{value, type}` | ✅ JSONB (ver `expressions/`) |
| Valor por pregunta | `question.expression` (AST, una expresión) = valor autocalculado solo lectura; se persiste como `answer` (`source = CALCULATED`, snapshot) | ✅ `question.expression`, `answer.source` (ver ADR 041) |
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
- **`bank/`**: carpeta (en `catalog/`) con las instancias JSON del catálogo.
  Planas por `kind` (`instruments/`, `clinical_history/`); la categoría es
  metadata (`list_categories[]`), no carpeta. Ver `catalog/bank/README.md`.
- **`reference/`**: documentación de referencia (no fuente de verdad), como el
  contrato del motor frontend.
- **`expressions/`**: gramática del AST y del envelope `form.expression`
  (`scoring`/`evaluation`/`subscales`) + `examples/` con ejemplos `.jsonc`
  reutilizables.
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
│   ├── question_types/  # Un doc por tipo de pregunta (config por tipo)
│   └── bank/            # Instancias JSON del catálogo
│       ├── README.md
│       ├── categories.json
│       ├── instruments/       # kind: INSTRUMENT (*.json)
│       └── clinical_history/  # kind: CLINICAL_HISTORY (*.json)
├── expressions/         # Lenguaje de expresiones (AST)
│   ├── README.md        # Índice + envelope expression/result
│   ├── operands.md      # Operandos y selectores
│   ├── conditions.md    # Condiciones de visibilidad (form/section/question)
│   ├── factories.md     # Factory functions (referencia)
│   ├── operators/       # Un doc por operador (math, case, aggregate, ...)
│   └── examples/        # Ejemplos .jsonc + casos médicos
├── responses/           # Capa ejecución / respuestas (V2)
│   ├── README.md
│   ├── ERD.mmd
│   ├── CLASS.mmd
│   └── example.jsonc
└── reference/           # Referencia (no fuente de verdad)
    └── questionnaire-engine.md  # Contrato del motor frontend
```

## Pendientes

Lista viva y detallada: [`../../TODO/cuestionarios.md`](../../TODO/cuestionarios.md).

- Confirmar el nombre del schema PostgreSQL (`form`) y añadirlo a `ALL_SCHEMAS`
  (`dh_shared/base.py`) — C10 (backend).
- Generar los JSON del banco (`catalog/bank/`) a partir de
  `docs/diagrams/<dominio>/flows/*.mmd` — ver `catalog/bank/README.md`.
- Motor frontend: faltan tipos y migración al AST completo (condición AST,
  `definitions`/`ref`, `time: minutes`, `case` condition-based) y al envelope
  `{value, type}` — D12 (frontend).
- Backend fase 2 (SQLAlchemy/repositorios) — F15.
