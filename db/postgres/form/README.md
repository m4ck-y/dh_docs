# Schema: Form

## Propósito

Esquema PostgreSQL para el **catálogo de cuestionarios** (encuestas y formularios
de salud): definición de los instrumentos (form, preguntas, opciones, secciones,
condiciones, scoring/interpretación) y el modelo de ejecución (`assignment` como
tarea/evento, `scheduled` como ventana de disponibilidad opcional y `answer`
como respuesta individual).

## Estado

En definición — diseño en curso.
El catálogo y la ejecución (V2) ya tienen DDL de referencia en `schema.sql`;
quedan abiertos el condicional estructurado (A1) y el `config` definitivo de
varios tipos de pregunta. El **lenguaje de expresiones**
(`scoring_expression` / `evaluation_expression`) ya está documentado en
[`features/questionnaires/expressions/`](../features/questionnaires/expressions/).

## Modelado en curso

El modelado completo del catálogo de cuestionarios —ERD relacional, diagrama de
clases/documentos (MongoDB) y ejemplos JSON— se desarrolla en
[`features/questionnaires/`](../features/questionnaires).

- **ERD del catálogo**:
  [`features/questionnaires/catalog/ERD.mmd`](../features/questionnaires/catalog/ERD.mmd)
- **Diagrama de clases / modelo de documentos**:
  [`features/questionnaires/catalog/CLASS.mmd`](../features/questionnaires/catalog/CLASS.mmd)

Una vez consolidado, el ERD PostgreSQL final se ubicará en esta carpeta
(`docs/db/postgres/form/`).

## Convenciones

- Cumple `.agents/rules/DOCUMENTATION_ERD.md` (relaciones → enums → entidades;
  tipos UPPERCASE; labels descriptivos) y
  `.agents/rules/MERMAID_ENUM_REPRESENTATION.md` (enums standalone con prefijo `E`).
- **BaseModel**: todas las tablas heredan `id` (Integer PK interno incremental),
  `uuid` (UUID externo), `created_at`, `updated_at`, `deleted_at`, `*_by_id_user`.
  Solo se anotan en el comentario del encabezado del ERD; no se listan como
  columnas (excepto `id`, mostrado por claridad).
- **FKs**: referencian el `id Integer` interno de la tabla destino (no el `uuid`).
- `EBiologicalSex` se comparte con `health_profile` (definido standalone en cada
  ERD, por convención Mermaid).
- **Excepción documentada**: las tablas puente N:N conservan `id` propio (no PK
  compuesta), a diferencia de la regla `PYTHON_INFRA_DB_BASE_MODEL.md` para N:N puras.

## Fuente

- **`schema.sql`** — DDL de referencia del modelo (definición + ejecución V2):
  [`features/questionnaires/schema.sql`](../features/questionnaires/schema.sql).
- **`FormsFlow2.drawio`** — primer modelo de datos del catálogo (retomado),
  3 pestañas: `Página-1` (ERD de definición), `FORM_DETAIL-ERD-JSON` (JSON
  aplanado), `anwers` (ejecución + DDL SQL + endpoints). Conservado en
  `reference_projects/reference_questionnaire_v1_legacy/`.

El ERD del catálogo se desarrolla en
`features/questionnaires/catalog/ERD.mmd`; una vez consolidado, se
ubicará en esta carpeta.

## Relaciones Externas

- **people**: `assignment.id_person` referencia `people.person`.
  **Nota**: `answer.answered_by` y los campos de auditoría de `assignment`
  (`started_by`, `completed_by`, `submitted_by`) referencian la entidad de
  **usuarios** (auth/iam), no `people.person`.
