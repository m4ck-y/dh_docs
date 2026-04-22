# care

Schema de PostgreSQL para relaciones de cuidado y responsabilidad entre personas.

Modela el vínculo entre un usuario (dependiente) y su tutor o responsable: tipo de parentesco, rol de cuidado y dependencia administrativa.

## Entidades

| Entidad | Descripción |
|---|---|
| `person_responsible` | Vinculación responsable-dependiente con tipo de relación (`ERelationship`) y rol de cuidado (`ECareRole`) |

## Enums

| Enum | Valores |
|---|---|
| `ERelationship` | `MOTHER`, `FATHER`, `CAREGIVER`, `LEGAL_GUARDIAN`, `OTHER` |
| `ECareRole` | `LIVES_WITH_AND_CARES`, `CARES_NOT_LIVING_WITH`, `ADMINISTRATIVE_SUPPORT_ONLY` |

## Archivos

| Archivo | Descripción |
|---|---|
| [erd.mmd](./erd.mmd) | Diagrama ERD del schema en Mermaid |
| [person_responsables.md](./person_responsables.md) | DDL SQL de la tabla `person_responsible` con notas de diseño |
