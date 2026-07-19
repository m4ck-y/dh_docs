**Proyecto o Apartado:** Core Domain / dh_shared / FHIR Practitioner

**Título de la actividad o tarea:** Implementación del Esquema Pydantic para el Recurso [Practitioner](https://hl7.org/fhir/R5/practitioner.html) (FHIR)

**Descripción de la actividad o tarea:**
Se implementó el esquema de validación Pydantic para el recurso FHIR [**Practitioner**](https://hl7.org/fhir/R5/practitioner.html) en la librería compartida `dh_shared`. Este recurso modela a las personas con responsabilidad formal en la provisión de servicios de salud (médicos, enfermeras, especialistas), distinguiéndose de [`RelatedPerson`](https://hl7.org/fhir/R5/relatedperson.html) (vínculos personales sin responsabilidad clínica formal) y de [`Patient`](https://hl7.org/fhir/R5/patient.html) (destinatario del cuidado). La implementación sigue la especificación FHIR R5 y se alinea con los recursos previamente creados ([`Patient`](https://hl7.org/fhir/R5/patient.html), [`Organization`](https://hl7.org/fhir/R5/organization.html), [`RelatedPerson`](https://hl7.org/fhir/R5/relatedperson.html)).

**Detalles Técnicos y de Código:**
Se programó la estructura en `dh_shared/src/dh_shared/schemas/shared/fhir/resources/practitioner.py`. Los componentes incluyen:

- [**Practitioner(DomainResource)**](https://hl7.org/fhir/R5/practitioner.html): Clase principal con `identifier` (lista de `Identifier`), `active`, `name` (lista de `HumanName`), `telecom` (lista de `ContactPoint`), `gender` (`AdministrativeGender`), `birthDate`, `deceased[x]` (choice type boolean/dateTime con validator para excluir ambos simultáneamente), `address` (lista de `Address`), `photo` (lista de `Attachment`), `qualification` (lista de `PractitionerQualification`) y `communication` (lista de `PractitionerCommunication`).

- **`PractitionerQualification(Element)`**: Backbone element para certificaciones y licencias profesionales, con `identifier`, `code` (`CodeableConcept` con binding a grado/licencia), `period` (`Period`) e `issuer` ([`Reference`](https://hl7.org/fhir/R5/organization.html) a `Organization` que regula la credencial).

- **`PractitionerCommunication(Element)`**: Preferencias lingüísticas del profesional, con `language` (`CodeableConcept`) y `preferred` (boolean).

- **Validaciones FHIR**: Se implementó `@model_validator(mode="after")` para el choice type `deceased[x]`, asegurando que `deceasedBoolean` y `deceasedDateTime` no puedan estar presentes simultáneamente.

**Estado de la actividad o tarea:** Concluido

**Avances de la actividad (si lo requiere):**
- Escritura del archivo `practitioner.py` siguiendo la misma arquitectura que `patient.py` y `related_person.py`.
- Implementación de `PractitionerQualification` como backbone element con campos identifier, code, period e issuer.
- Implementación de `PractitionerCommunication` para soporte multilingüe del profesional.
- Validación del choice type deceased[x] mediante model_validator, consistente con el patrón usado en `Patient`.
- Sincronización de imports con la jerarquía existente de datatypes y value sets en `dh_shared`.
