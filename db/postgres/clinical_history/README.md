# clinical_history

Schema de PostgreSQL para el **historial clínico** con trazabilidad temporal.

> **Adoptado** desde la propuesta [`../todo/propuesta_schemes_2.md`](../todo/propuesta_schemes_2.md).
> El modelo vive en el **ERD** ([`erd.mmd`](./erd.mmd)); no se mantienen DDL `.md` por tabla.

## Entidades

| Entidad | Descripción | Estado |
|---|---|---|
| `condition` | Condiciones/enfermedades de la persona (CIE-11) | ✅ |
| `encounter` | Consultas / atenciones | ⏳ pendiente de diseño |
| `encounter_diagnosis` | Puente condición ↔ consulta | ⏳ pendiente (depende de `encounter`) |

## Enums

| Enum | Valores |
|---|---|
| `EConditionCategory` | `PROBLEM_LIST`, `ENCOUNTER_DIAGNOSIS` |
| `EConditionClinicalStatus` | `ACTIVE`, `RECURRENCE`, `RELAPSE`, `INACTIVE`, `REMISSION`, `RESOLVED` |
| `EConditionSeverity` | `MILD`, `MODERATE`, `SEVERE` |

## Notas

- `condition` **unifica** el antes `health_profile.chronic_condition` y la propuesta
  `diagnosis_record`.
- **Sin consulta**: una condición puede existir **sin** `encounter` (la detectó el
  paciente, o se perdió la data) → el vínculo va por el **puente**
  `encounter_diagnosis` (opcional).
- **`contributed_to_death`**: marca que la condición contribuyó a la muerte
  (FHIR `FamilyMemberHistory.condition.contributedToDeath`). La **causa** de muerte
  también se guarda en `health_profile.death` (`cause_code`/`cause_text`).
- `category` default **`PROBLEM_LIST`** (AHF/D); `ENCOUNTER_DIAGNOSIS` cuando la
  condición proviene de una consulta.
- Enums en **inglés**.
