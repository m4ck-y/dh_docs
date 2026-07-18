# TASK-014 — Planeacion

## Objetivo

Establecer la capa de modelado clinico interoperable del ecosistema Digital Hospital mediante la adopcion de HL7 FHIR R5:

1. Implementar schemas Pydantic en `dh_shared`.
2. Construir el servicio `dh_fhir` para descarga y consulta de especificaciones.

## Alcance

### Fase 1 — Fundamentos
- Clases base: `Element`, `Resource`, `DomainResource`.
- Datatypes complejos: `Address`, `CodeableConcept`, `Reference`, `HumanName`, `Identifier`, `Period`, `Quantity`, etc.
- ValueSets basicos: `address_use`, `name_use`, `contact_point_system`, etc.

### Fase 2 — Recursos de Identidad y Organizacion
- `Patient`, `Practitioner`, `Organization`, `RelatedPerson`, `HealthcareService`, `PractitionerRole`.

### Fase 3 — Recursos Clinicos
- `Encounter`, `Location`, `Endpoint`, `Observation`, `Condition`, `AllergyIntolerance`, `Procedure`, `ClinicalImpression`.
- `FamilyMemberHistory`, `MedicationStatement`, `DocumentReference`, `Composition`, `MedicationRequest`.

## Criterios de Priorizacion

1. **Expediente clinico longitudinal**: recursos que permiten representar la historia de salud de un paciente.
2. **Dependencias internas minimas**: priorizar recursos que no requieran muchos otros recursos no implementados.
3. **Alineacion regulatoria**: mapeo con NOM-024 y expediente clinico mexicano.

## Convenciones

- Herencia: `Element` → `Resource` → `DomainResource` → recurso.
- `resourceType` como `@computed_field` en `Resource`.
- `CodeableConcept[SpecificEnum]` para bindings Required/Extensible/Preferred.
- `Reference[SomeResource]` para targets explicitos.
- Timestamps UTC; `datetime.utcnow()` prohibido.

## Dependencias Tecnicas

- `pydantic>=2.0`
- `beanie>=2.1.0` (solo para contextos MongoDB futuros)
- `httpx` para llamadas async a Jina AI
- `aiosqlite` para metadata de descargas en `dh_fhir`
