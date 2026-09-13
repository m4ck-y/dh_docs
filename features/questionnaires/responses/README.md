# Capa responses — Ejecución de cuestionarios (V2)

Modelo de **ejecución** de cuestionarios: la asignación de un instrumento a una
persona y las respuestas resultantes. La definición del instrumento (catálogo)
se documenta aparte en [`../catalog/`](../catalog/).

## Fuente de verdad

- **`../schema.sql`** — copia de referencia del DDL de
  `other_projects/app_questionnaire/backend/docs/db_ddl.sql`. La sección de
  ejecución del DDL es la fuente de verdad de esta capa.
- **Legacy**: `other_projects/app_questionnaire/backend/docs/bd_mermaid.mmd`
  (modelo V1, ver "Diferencias V1 → V2").
- Reglas de formato: `.agents/rules/DOCUMENTATION_ERD.md` y
  `.agents/rules/MERMAID_ENUM_REPRESENTATION.md`.

## Diagrama

`ERD.mmd` modela el flujo de respuestas con `assignment` como **tarea/evento**
(no como registro maestro).

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

## Diferencias V1 → V2

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

## Nota sobre referencias a usuarios

`assigned_by`, `answered_by`, `started_by`, `completed_by` y `submitted_by` son
**referencias a la entidad de usuarios** (FK), no enums. Se escriben sin sufijo
`id_`/`user` por convención de este dominio.

## Archivos de esta capa

| Archivo | Contenido |
|---|---|
| `ERD.mmd` | ERD relacional de ejecución: `assignment` (tarea/evento), `scheduled`, `answer`. |
| `CLASS.mmd` | Diagrama de clases / vista de documentos (MongoDB) de ejecución. |
| `example.jsonc` | Ejemplo de payload de ejecución/respuestas (modelo V2). |

## Pendientes de esta capa

- Confirmar el nombre del schema PostgreSQL (`form`) y añadirlo a `ALL_SCHEMAS`
  (`dh_shared/base.py`).
- Modelo de ejecución (V2) → DDL: verificar que `schema.sql` no conserve
  `form_direct_responses` / `scheduled_responses` del modelo V1.
