# Sesion de LLM - 2026-04-22

**Objetivo**: Revisar y corregir diagramas ERD de Mermaid para el schema `person`

## Cambios Realizados

### 1. Reglas Actualizadas

| Archivo | Cambio |
|---------|--------|
| `dev-style-guide/rules/DOCUMENTATION_ERD.md` | v2.0.0 - Naming conventions, SQL types |
| `dev-style-guide/rules/MERMAID_ENUM_REPRESENTATION.md` | v2.0.0 - Enum placement y tipos |

### 2. Diagramas ERD Corregidos

| Schema | Archivo | Cambios |
|--------|---------|--------|
| `people/` | `erd.mmd` | Enums en uppercase, tablas en lowercase, comentarios %% |
| `expedient/` | `erd.mmd` | Tablas de document renombradas a `expedient` |
| `care/` | `erd.mmd` | Schema nuevo con `person_responsible` |
| `health_profile/` | `erd.mmd` | Schema nuevo con `biological_profile` |

### 3. Reestructuracion de Carpetas

```
docs/db/postgres/
├── README.md
├─�� catalog/       (vacío)
├── care/         (person_responsible)
├── expedient/    (document, document_type, document_category)
├── health_profile/ (biological_profile, person_allergy, chronic_condition)
├── people/       (person, email, phone, address, profile, etc)
└── public/       (vacío)
```

### 4. Enums Agregados

| Enum | Schema | Valores |
|------|--------|--------|
| `EVerificationStatus` | people | REJECTED, PENDING, APPROVED |
| `EGenderIdentity` | people | NO_ESPECIFICADO=0...OTRO=88 |
| `ESocialPlatform` | people | TWITTER...OTHER |
| `EIdentifierType` | people | NATIONAL_ID=1...SOCIAL_SECURITY_ID=3 |
| `EAddressType` | people | HOME=1...OTHER=10 |
| `EEmailType` | people | PERSONAL=2...OTHER=10 |
| `EPhoneType` | people | MOBILE=1...OTHER=10 |
| `ERelationshipContact` | people | SPOUSE...OTHER |
| `EEducationLevel` | people | NO_STUDIES=0...PREFERS_NOT_TO_SAY=99 |
| `EIncomeRange` | people | NO_INCOME=0...PREFERS_NOT_TO_SAY=99 |
| `ERelationship` | care | MOTHER...OTHER |
| `ECareRole` | care | LIVES_WITH_AND_CARES...ADMINISTRATIVE_SUPPORT_ONLY |
| `EEconomicDependence` | care | YES, PARTIALLY, NO |
| `EBiologicalSex` | health_profile | HOMBRE=1...INTERSEXUAL=3 |
| `EBloodType` | health_profile | A+...O- |

### 5. Tablas Modificadas/Agregadas

| Tabla | Schema | Notas |
|------|--------|-------|
| `person_identifier` → `personal_identifier` | people | Renombrada |
| `emergency_contact` | people | Nueva tabla |
| `profile` | people | Agregados `education_level`, `income_range` |
| `person_responsible` | care | Nueva con `economic_dependence` |
| `biological_profile` | health_profile | Nueva con FK a person |
| `person_allergy` | health_profile | Nueva (1:N) |
| `chronic_condition` | health_profile | Nueva (1:N) |
| `vaccination_record` | health_profile | Nueva (1:N) |

### 6. Enums Removidos de people

- `EBiologicalSex` movido a `health_profile`

### 7. Tablas Removidas

- `document_identifier` eliminada (simplificado a FK nullable en `personal_identifier`)

---

*Reporte generado: 2026-04-22*