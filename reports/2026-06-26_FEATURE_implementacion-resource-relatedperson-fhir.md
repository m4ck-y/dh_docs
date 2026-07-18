**Proyecto o Apartado:** Core Domain / dh_shared / FHIR RelatedPerson

**Título de la actividad o tarea:** Implementación del Esquema Pydantic para el Recurso RelatedPerson (FHIR R5)

**Descripción de la actividad o tarea:**
Se diseñó e implementó el esquema Pydantic para el recurso FHIR **[RelatedPerson](https://hl7.org/fhir/R5/relatedperson.html)** en la librería compartida de schemas `dh_shared`. Este recurso modela a personas involucradas en el cuidado o estado de salud de un paciente (como familiares, tutores, vecinos o contactos de emergencia) que no poseen una responsabilidad clínica o profesional formal en el proceso. Con esto se proporciona un mecanismo para establecer la red de apoyo del paciente y su contacto legal.

La clase principal `RelatedPerson` hereda de `DomainResource` e incorpora relaciones directas mediante referencias tipadas al recurso [`Patient`](https://hl7.org/fhir/R5/patient.html). Se integraron tipos de datos complejos como `HumanName` para nombres estructurados, `Address` para direcciones, y `ContactPoint` para medios de contacto. También se implementó el sub-elemento `RelatedPersonCommunication` para registrar las preferencias de idioma de los contactos al comunicarse sobre la salud del paciente.

El diseño de este esquema contempla la flexibilidad requerida para capturar el entorno social y familiar del paciente, permitiendo registrar múltiples contactos con roles diversos (como tutores legales o acompañantes de salud). La inclusión de validaciones nativas de Pydantic asegura la consistencia de las referencias cruzadas y los medios de telecomunicación asociados, previniendo fallas de validación de datos en tiempo de ejecución.

**Estado de la actividad o tarea:** Concluido

**Avances de la actividad (si lo requiere):**
- Creación de la clase `RelatedPerson` en `dh_shared/src/dh_shared/schemas/shared/fhir/resources/related_person.py`.
- Vinculación del campo `patient` como una referencia fuertemente tipada a `Patient` (`Reference[Patient]`).
- Implementación de la lista de relaciones (`relationship`) utilizando `CodeableConcept` asociado al ValueSet `ContactRelationship`.
- Diseño del elemento de comunicación `RelatedPersonCommunication` estructurado con el campo `language` mapeado al ValueSet `AllLanguages`.
- Integración de datatypes estándar como `Identifier`, `HumanName`, `Address`, `ContactPoint`, `Attachment` y `Period`.
