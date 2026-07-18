# ADR 036: Adopcion de FHIR R5 como Estandar de Interoperabilidad Clinica

## Estado

Aceptado

## Contexto

El ecosistema Digital Hospital necesita representar informacion clinica estructurada (pacientes, alergias, condiciones, encuentros, medicacion, observaciones, documentos) de forma interoperable con otros sistemas de salud. Sin un estandar, cada microservicio definiria sus propios modelos de datos, generando duplicacion y fragmentacion.

Se evaluaron las siguientes opciones:

| Opcion | Pros | Contras |
|---|---|---|
| Modelos propios por servicio | Control total, rapido inicialmente | Fragmentacion, duplicacion, sin interoperabilidad |
| FHIR R4 | Maduro, amplia adopcion | Recursos y bindings ligeramente diferentes a R5 |
| FHIR R5 | Version mas reciente del estandar HL7, modelo alineado con la vision del proyecto, bindings refinados | Menos implementaciones de referencia, documentacion en evolucion |
| OpenEHR | Enfoque en arquetipos clinicos | Curva de aprendizaje alta, menor adopcion en la region |

## Decision

**Adoptar HL7 FHIR R5 como estandar canonico para modelado de recursos clinicos en Digital Hospital.**

### Alcance

1. **dh_shared**: Implementar schemas Pydantic para recursos FHIR R5 en `dh_shared.schemas.shared.fhir`, incluyendo:
   - `resources/` — 19 recursos de dominio clinico iniciales.
   - `datatypes/` — 25 tipos de datos complejos.
   - `valueset/` — enums para bindings Required/Extensible/Preferred.
   - `extensibility/` — elementos de extension base.

2. **dh_fhir**: Servicio de soporte para descargar y consultar especificaciones FHIR R5 via Jina AI, almacenando copias locales en `files/`.

3. **Microservicios clinicos futuros**: Consumir los schemas de `dh_shared` para validacion de entrada/salida y serializacion JSON compatible con FHIR.

### Criterios de Seleccion de Recursos

Los recursos se priorizan segun:

1. Necesidad para el expediente clinico longitudinal del paciente.
2. Dependencias minimas con recursos aun no implementados.
3. Relevancia para cumplimiento regulatorio mexicano (NOM-024).

Recursos iniciales (fase 1): Patient, Practitioner, Organization, RelatedPerson, HealthcareService, PractitionerRole.

Recursos clinicos (fase 2): Encounter, Location, Observation, Condition, AllergyIntolerance, Procedure, ClinicalImpression, FamilyMemberHistory, MedicationStatement, DocumentReference, Composition, MedicationRequest, Endpoint.

### Convenciones de Implementacion

- Herencia: `Resource` → `DomainResource` → recurso especifico.
- Backbone elements como clases anidadas que heredan de `Element`.
- `resourceType` como `@computed_field` en la clase base.
- Bindings Required/Extensible/Preferred se implementan como `CodeableConcept[SpecificEnum]`.
- Campos `Reference(SomeResource)` se tipan como `Reference[SomeResource]`.
- Timestamps en UTC; sin `datetime.utcnow()`.

## Consecuencias

- **Positivas**:
  - Modelado clinico estandarizado e interoperable.
  - Unica fuente de verdad para schemas clinicos en `dh_shared`.
  - Facilita integraciones futuras con hospitales, laboratorios y sistemas de terceros.
  - Reduce duplicacion entre microservicios.

- **Negativas**:
  - Curva de aprendizaje del equipo en FHIR R5.
  - Mantenimiento continuo ante cambios en el estandar HL7.
  - Algunos recursos requieren clases stub o referencias circulares.

## Referencias

- [Research: Adopcion de HL7 FHIR R5](../research/fhir-r5-interoperability.md)
- [Reporte: Exploracion del estandar FHIR](../reports/2026-05-27_ARCH_exploracion-estandar-interoperabilidad-fhir.md)
- [Reporte: Propuesta de mapeo NOM-024 a FHIR](../reports/2026-05-29_ARCH_propuesta-mapeo-nom024-fhir.md)
- [HL7 FHIR R5 Specification](https://hl7.org/fhir/R5/)
- [dh_shared FHIR AGENTS.md](../dh_shared/src/dh_shared/schemas/shared/fhir/AGENTS.md)
