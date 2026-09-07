# Catálogo de cuestionarios — modelo de datos

Punto de entrada al modelo de datos del **catálogo de cuestionarios**: la
**definición** del instrumento (form, question) y la **ejecución**
(assignment, scheduled, response, answer).

## Fuente de verdad

- **`db_ddl.sql`** — copia de referencia del DDL de
  `other_projects/app_questionnaire/backend/docs/db_ddl.sql`. Es la **única
  fuente de verdad/legacy** del modelo:
  - Definición: `form` (con `scoring_expression`, `evaluation_expression`,
    `verified`) y `question` (con `key`, `question_type`, `config JSONB`,
    `position`).
  - Ejecución: `assignment`, `scheduled`, `response`, `answer`,
    `form_direct_responses`, `scheduled_responses` + triggers de exclusión
    directo/programado.
- Reglas de formato: `.agents/rules/DOCUMENTATION_ERD.md` y
  `.agents/rules/MERMAID_ENUM_REPRESENTATION.md`.
- Referencia (no fuente de verdad): contrato del motor frontend en
  `docs/diagrams/schemas/cuestionario/README.md`.

## ERD canónico

- **`ERD_questionnaires.mmd`** — ERD Mermaid del catálogo (schema `form`).
  Alineado con la fuente de verdad:
  `scoring_expression`, `evaluation_expression` y `verified` ya están en el ERD.

> El antiguo `erd-catalogo.mmd` (schema `catalog`, tablas `questionnaire_*`)
> fue eliminado: era un híbrido no fiel al DDL ni al drawio. Sus ideas nunca
> confirmadas quedan como decisiones abiertas.

## Decisiones abiertas (el DDL no las resuelve)

| Tema | Opciones | Qué dice el DDL |
|---|---|---|
| Opciones de respuesta | Tabla propia vs embebidas en `question.config` | Embebidas en `config` |
| Condicional | Fórmula libre vs declarativo (`behavior`/`operator`/`value`) | Sin tabla propia (iría en `config`) |
| Agrupación | `section` vs ítems anidados (`parent_item_id`) | No existe |
| Schema PostgreSQL | `form` vs `catalog` | Sin schema explícito |
| Metadatos (categorías, CIE-11, referencias, edad/sexo, duración) | Tablas normalizadas vs campos planos | No existen |

## Archivos

| Archivo | Contenido |
|---|---|
| `db_ddl.sql` | Fuente de verdad: DDL de definición + ejecución. |
| `ERD_questionnaires.mmd` | ERD del catálogo de cuestionarios (definición). |
| `questionnaire_example.jsonc` | Ejemplo de payload del catálogo (JSON con comentarios). |
| `ERD_response.mmd` *(pendiente)* | ERD de ejecución/respuestas (`assignment`, `response`, `answer`). |
| `response_example.jsonc` *(pendiente)* | Ejemplo de payload de respuesta. |

## Convención de nombres

- **`ERD_<dominio>.mmd`**: diagrama entidad-relación del dominio.
  - `questionnaires` = definición del instrumento (catálogo).
  - `response` = ejecución y respuestas (`assignment`, `response`, `answer`).
- **`<dominio>_example.jsonc`**: ejemplo de payload del dominio.
  - Extensión `.jsonc` porque incluye comentarios `/* */`.
  - Si un ejemplo no necesita comentarios, puede usarse `.json`.

## Pendientes

- Resolver PHQ-9 ítem 7 (contenido, no schema).
- Modelar la ejecución (`assignment`/`response`/`answer`) como ERD aparte,
  alineado al DDL.
- Confirmar el nombre del schema PostgreSQL y añadirlo a `ALL_SCHEMAS`
  (`dh_shared/base.py`).
