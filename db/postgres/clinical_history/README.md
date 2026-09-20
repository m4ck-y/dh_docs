# clinical_history

Schema de PostgreSQL para el **historial clínico** con trazabilidad temporal.

> **Adoptado** desde la propuesta [`../todo/propuesta_schemes_2.md`](../todo/propuesta_schemes_2.md).
> El modelo vive en el **ERD** ([`erd.mmd`](./erd.mmd)); no se mantienen DDL `.md` por tabla.

## Entidades

| Entidad | Descripción | Estado |
|---|---|---|
| `condition` | Condiciones/enfermedades de la persona (CIE-11) | ✅ |
| `medication_statement` | Medicamentos de la persona (reportados; FHIR `MedicationStatement`) | ✅ ([contrato](../../features/clinical_history/contracts/medication_statement.md)) |
| `medication_condition` | Puente N:N medicamento ↔ condición ("motivo") | ✅ |
| `encounter` | Consultas / atenciones | ⏳ pendiente de diseño |
| `encounter_diagnosis` | Puente condición ↔ consulta | ⏳ pendiente (depende de `encounter`) |

## Enums

| Enum | Valores |
|---|---|
| `EConditionCategory` | `PROBLEM_LIST`, `ENCOUNTER_DIAGNOSIS` |
| `EConditionClinicalStatus` | `ACTIVE`, `RECURRENCE`, `RELAPSE`, `INACTIVE`, `REMISSION`, `RESOLVED` |
| `EConditionSeverity` | `MILD`, `MODERATE`, `SEVERE` |
| `EMedicationStatementStatus` | `ACTIVE`, `COMPLETED`, `STOPPED`, `ON_HOLD`, `ENTERED_IN_ERROR` |
| `EMedicationAdherence` | `ALWAYS`, `SOMETIMES`, `NEVER`, `UNKNOWN` |
| `EInformationSource` | `PATIENT`, `RELATIVE`, `CLINICIAN` |

## Notas

- `condition` **unifica** el antes `health_profile.chronic_condition` y la propuesta
  `diagnosis_record`.
- `medication_statement` = lo que **toma la persona** (reportado), según FHIR
  `MedicationStatement`: la **dosis es por persona**, no del producto. Su contrato
  de componente vive en [`features/clinical_history/contracts/medication_statement.md`](../../features/clinical_history/contracts/medication_statement.md).
- **Referencia al catálogo**: `medication_code_system` + `medication_code`
  (`CodeableConcept`) apunta a un ítem del catálogo **`medication`** (Vademecum,
  ClickHouse) — referencia **suave** (cross-engine, **sin FK**).
- **Motivo (N:N)**: `medication_condition` liga un medicamento con **varias**
  condiciones (y una condición con varios medicamentos) — FHIR
  `MedicationStatement.reason`.
- **Sin consulta**: una condición puede existir **sin** `encounter` (la detectó el
  paciente, o se perdió la data) → el vínculo va por el **puente**
  `encounter_diagnosis` (opcional).
- **`contributed_to_death`**: marca que la condición contribuyó a la muerte
  (FHIR `FamilyMemberHistory.condition.contributedToDeath`). La **causa** de muerte
  también se guarda en `health_profile.death` (`cause_code`/`cause_text`).
- `category` default **`PROBLEM_LIST`** (AHF/D); `ENCOUNTER_DIAGNOSIS` cuando la
  condición proviene de una consulta.
- `medication_statement.name` = display / fallback si no hay código.
- Enums en **inglés**.
