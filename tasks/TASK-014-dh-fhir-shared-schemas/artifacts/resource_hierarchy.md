# Jerarquia de Recursos FHIR Implementados

```mermaid
flowchart TD
    P["Patient"] --> F["FamilyMemberHistory"]
    P --> A["AllergyIntolerance"]
    P --> C["Condition"]
    P --> E["Encounter"]
    E --> O["Observation"]
    E --> PR["Procedure"]
    E --> CI["ClinicalImpression"]
    E --> MR["MedicationRequest"]
    E --> CO["Composition"]
    P --> MS["MedicationStatement"]
    P --> DR["DocumentReference"]
```

## Recursos por Fase

| Fase | Recursos |
|---|---|
| Identidad | Patient, Practitioner, Organization, RelatedPerson |
| Servicios | HealthcareService, PractitionerRole, Endpoint, Location |
| Encuentro | Encounter, Appointment |
| Clinicos | Observation, Condition, AllergyIntolerance, Procedure, ClinicalImpression |
| Historia | FamilyMemberHistory |
| Medicacion | MedicationStatement, MedicationRequest |
| Documentacion | DocumentReference, Composition |

## Estado General

- **19 recursos** implementados.
- **25 datatypes** implementados.
- **70+ valuesets** implementados.
- Ver tabla completa en [`docs/STATUS.md`](../../../STATUS.md).
