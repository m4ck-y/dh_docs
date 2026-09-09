# Catálogo de cuestionarios — modelo de datos

Punto de entrada al modelo de datos del **catálogo de cuestionarios**: la
**definición** del instrumento (form, question) y la **ejecución**
(assignment, scheduled, response, answer).

## Fuente de verdad

- **`db_ddl.sql`** — copia de referencia del DDL de
  `other_projects/app_questionnaire/backend/docs/db_ddl.sql`. Es la **única
  fuente de verdad/legacy** del modelo:
  - Definición: `form` (con `scoring_expression`, `evaluation_expression`,
    `verified`) y `question` (con `key`, `type`/`EQuestionType`, `order`).
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

## Diagrama de clases / modelo de documentos

Además del ERD relacional, se mantiene `CLASS_questionnaires.mmd`: una
representación orientada a objetos/documentos del mismo dominio. Su propósito es
mostrar cómo se vería el catálogo de cuestionarios si se persiste en una base de
datos NoSQL (p. ej. MongoDB), donde `Form`, `Section`, `Question`, `Option`,
`Conditional` y `Url` se modelan como documentos/subdocumentos embebidos en lugar
de tablas normalizadas.

- Las relaciones de composición (`◆`) indican subdocumentos embebidos.
- Las relaciones de agregación/asociación (`◇`, `──>`) indican referencias a
  otros documentos.
- `CLASS_questionnaires.mmd` no reemplaza al ERD del catálogo; son dos vistas
  del mismo modelo para dos tecnologías de persistencia distintas.

## Limitantes del modelo de documentos

Al usar un diseño orientado a documentos hay que tener en cuenta:

- **Límite de 16 MB por documento en MongoDB**: un cuestionario muy grande podría
  acercarse a este tope si se embeben todas las preguntas, opciones y metadatos
  en un solo documento. Para los instrumentos actuales (GDS-15, PHQ-9, etc.) no
  es un problema.
- **Embebido vs. referencia**: embeber es eficiente para lectura, pero dificulta
  reutilizar preguntas/opciones entre formularios. Si se necesita reutilización,
  conviene usar referencias a otra colección.
- **Duplicación de datos**: metadatos como categorías, referencias, duración
  estimada, grupos de edad, etc., pueden repetirse en cada documento si se
  embeben. Evaluar si vale la pena normalizarlos en colecciones aparte.
- **Ausencia de esquema rígido**: MongoDB no impone un esquema, por lo que
  `CLASS_questionnaires.mmd` actúa como convenio de aplicación, no como
  restricción de la base de datos.

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

## Decisiones abiertas

- Confirmar el nombre del schema PostgreSQL (`form` propuesto) y añadirlo a
  `ALL_SCHEMAS` (`dh_shared/base.py`).

## Modelo de ejecución (V2)

El flujo de respuestas se modela en `ERD_responses.mmd` con `assignment` como
**tarea/evento** (no como registro maestro). Ver detalles en el encabezado y
comentarios del propio ERD.

### Entidades

| Entidad | Rol |
|---|---|
| `form` | Plantilla inmutable del cuestionario (compartida con el catálogo). |
| `assignment` | Tarea/evento único. Cada re-contestación o renovación crea una nueva `assignment`. |
| `scheduled` | Ventana de disponibilidad **opcional** (solo si un profesional lo programó). |
| `answer` | Respuesta a una pregunta individual, con `answered_by`. |

### Cardinalidades

| Relación | Cardinalidad | Justificación |
|---|---|---|
| `form → assignment` | `\|\|--o{` | Cero o muchas: un form del catálogo puede existir sin asignaciones; cada assignment pertenece a un único form. |
| `assignment → scheduled` | `\|\|--o\|` | Cero o una programación. `o` cubre el flujo directo (paciente auto-contesta, sin programar). |
| `assignment → answer` | `\|\|--o{` | Cero o muchas: una assignment `ENABLED` aún no tiene respuestas; cada answer pertenece a una única assignment. |

### Decisiones técnicas

| Tema | Decisión | Motivo |
|---|---|---|
| `assignment` como evento | No es registro maestro; cada contestación es un evento nuevo | Evita la ambigüedad entre "reintentos" y "actualizaciones de info". |
| `assigned_by` solo en `scheduled` | El asignador se guarda en `scheduled`, no en `assignment` | En flujo directo no hay asignador (el paciente contesta por su cuenta). |
| `answered_by` en `answer` | Auditoría por pregunta: quién ingresó cada respuesta | En salud, a veces el médico o tutor contesta por el paciente. |
| `scoring_result` en `assignment` | No es cache, es el resultado del evento | `assignment` es la unidad que produce el resultado. |
| `status` enum | `ENABLED`, `IN_PROGRESS`, `COMPLETED`, `SUBMITTED`, `EXPIRED` | Ciclo de vida de una tarea; ver comentarios del ERD. |

### Diferencias V1 → V2

El modelo V1 (referencia `other_projects/app_questionnaire/backend/docs/bd_mermaid.mmd`)
definía la ejecución con `response` intermedia y tablas puente. V2 los elimina:

| Elemento V1 | Resolución en V2 |
|---|---|
| `response` (sesión intermedia con `status`/`attempt_number`) | Eliminada: la sesión vive en `assignment` (timestamps, status, resultados). |
| `attempt_number` (reintentos dentro de una assignment) | Sin reintentos: cada re-contestación crea una nueva `assignment` (tarea/evento). |
| Puentes `form_direct_responses` / `scheduled_responses` (+ triggers de exclusividad) | Eliminados: `scheduled` 0..1 opcional cubre el flujo directo. |
| Estado `DISABLED` | Omitido del enum: se representa con soft-delete de `BaseModel` (`deleted_at`). Documentado como comentario en ERD y DDL. |
| `n_questions_total` / `n_questions_answered` (cache de progreso) | No se persisten: se calculan desde `answer`. Documentado como comentario en ERD y DDL. |
| `id_responder_user` (quién respondió la sesión) | `answered_by` por `answer` + `started_by`/`completed_by`/`submitted_by` en `assignment`. |
| `assignment \|\|--o{ scheduled` (N ventanas por assignment) | `assignment \|\|--o\| scheduled`: una sola ventana; reprogramar = nueva assignment. |

### Nota sobre referencias a usuarios

`assigned_by`, `answered_by`, `started_by`, `completed_by` y `submitted_by` son
**referencias a la entidad de usuarios** (FK), no enums. Se escriben sin sufijo
`id_`/`user` por convención de este dominio.

## Archivos

| Archivo | Contenido |
|---|---|
| `db_ddl.sql` | Fuente de verdad: DDL de definición + ejecución. |
| `ERD_questionnaires.mmd` | ERD del catálogo de cuestionarios (definición relacional). |
| `CLASS_questionnaires.mmd` | Diagrama de clases del catálogo (vista de documentos/MongoDB). |
| `questionnaire_example.jsonc` | Ejemplo de payload del catálogo (JSON con comentarios). |
| `ERD_responses.mmd` | ERD de ejecución: `assignment` (tarea/evento), `scheduled`, `answer`. |
| `CLASS_responses.mmd` | Diagrama de clases de ejecución (vista de documentos/MongoDB). |
| `response_example.jsonc` | Ejemplo de payload de ejecución/respuestas (modelo V2). |

## Convención de nombres

- **`ERD_<dominio>.mmd`**: diagrama entidad-relación del dominio.
  - `questionnaires` = definición del instrumento (catálogo).
  - `responses` = ejecución y respuestas (`assignment`, `scheduled`, `answer`).
- **`CLASS_<dominio>.mmd`**: diagrama de clases / vista de documentos del dominio.
- **`<dominio>_example.jsonc`**: ejemplo de payload del dominio.
  - Extensión `.jsonc` porque incluye comentarios `/* */`.
  - Si un ejemplo no necesita comentarios, puede usarse `.json`.

## Pendientes

- Resolver PHQ-9 ítem 7 (contenido, no schema).
- Confirmar el nombre del schema PostgreSQL y añadirlo a `ALL_SCHEMAS`
  (`dh_shared/base.py`).
