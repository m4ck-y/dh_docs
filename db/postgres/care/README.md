# care

Schema de PostgreSQL para relaciones de cuidado y responsabilidad entre personas.

Modela el vinculo entre un usuario (dependiente) y su tutor o responsable: tipo de parentesco, rol de cuidado y dependencia administrativa.

## Entidades

| Entidad | Descripcion |
|---|---|
| `person_responsible` | Vinculacion responsable-dependiente con tipo de relacion (`ERelationship`) y rol de cuidado (`ECareRole`) |

## Enums

| Enum | Valores |
|---|---|
| `ERelationship` | `MOTHER`, `FATHER`, `CAREGIVER`, `LEGAL_GUARDIAN`, `OTHER` |
| `ECareRole` | `LIVES_WITH_AND_CARES`, `CARES_NOT_LIVING_WITH`, `ADMINISTRATIVE_SUPPORT_ONLY` |

## Archivos

| Archivo | Descripcion |
|---|---|
| [erd.mmd](./erd.mmd) | Diagrama ERD del schema en Mermaid |
| [person_responsables.md](./person_responsables.md) | DDL SQL de la tabla `person_responsible` con notas de diseno |

## Tablas futuras potenciales

| Tabla | Descripcion |
|---|---|
| `care_plan` | Plan de cuidados (cronicos/post-operatorios) |
| `caregiver_assignment` | Asignacion cuidador->paciente |
| `care_visit` | Visitas de cuidado a domicilio |
| `care_activity` | Actividades de cuidado realizadas |
| `care_note` | Notas del cuidador |
| `care_level` | Nivel de cuidado (bajo/medio/alto) |
| `care_schedule` | Horario de cuidados |