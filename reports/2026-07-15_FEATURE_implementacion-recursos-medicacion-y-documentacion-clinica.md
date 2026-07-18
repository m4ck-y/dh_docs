**Proyecto o Apartado:** Core Domain / dh_shared / FHIR Medicación y Documentación

**Título de la actividad o tarea:** Implementación de Esquemas Pydantic para MedicationRequest, MedicationStatement, DocumentReference y Composition

**Descripción de la actividad o tarea:**
Se diseñaron e implementaron los esquemas de validación Pydantic para los recursos de gestión farmacológica y gestión documental **[MedicationRequest](https://hl7.org/fhir/R5/medicationrequest.html)**, **[MedicationStatement](https://hl7.org/fhir/R5/medicationstatement.html)**, **[DocumentReference](https://hl7.org/fhir/R5/documentreference.html)** y **[Composition](https://hl7.org/fhir/R5/composition.html)** en la librería compartida de schemas `dh_shared`. Bajo el estándar HL7 FHIR R5, estos recursos permiten modelar de forma precisa el ciclo de prescripción de medicamentos, el consumo reportado de sustancias terapéuticas y la estructuración de documentos clínicos consolidados.

- **[`MedicationRequest`](https://hl7.org/fhir/R5/medicationrequest.html)** representa las órdenes de prescripción farmacológica emitidas por profesionales médicos, detallando medicamentos indicados, dosificación, instrucciones de dispensación y autorizaciones de repetición.
- **[`MedicationStatement`](https://hl7.org/fhir/R5/medicationstatement.html)** registra la declaración de consumo de medicamentos por parte del paciente (sea recetado o auto-administrado), sirviendo para consolidar la conciliación de medicamentos activos e históricos.
- **[`DocumentReference`](https://hl7.org/fhir/R5/documentreference.html)** proporciona metadatos técnicos y referencias a documentos clínicos externos (PDFs, imágenes de diagnóstico o registros escaneados) almacenados en repositorios externos de Digital Hospital.
- **[`Composition`](https://hl7.org/fhir/R5/composition.html)** estructura un conjunto de datos clínicos en un único documento clínico cohesionado (notas de evolución, resúmenes de alta, reportes de consulta), organizándolos en secciones lógicas mediante la clase `CompositionSection` y gestionando la firma de validez a través de `CompositionAttester`.

La implementación de estos esquemas completa el ciclo terapéutico y documental del historial del paciente. La capacidad de registrar tanto las órdenes de medicación (`MedicationRequest`) como el consumo real declarado (`MedicationStatement`), combinada con la consolidación en composiciones clínicas firmadas (`Composition`), asegura la integridad del expediente médico electrónico y el soporte de auditorías legales y clínicas.

**Estado de la actividad o tarea:** Concluido

**Avances de la actividad (si lo requiere):**
- Creación e integración de los schemas en los archivos correspondientes bajo `dh_shared/src/dh_shared/schemas/shared/fhir/resources/`.
- Modelado de sub-estructuras complejas como `CompositionSection`, `CompositionAttester`, `CompositionEvent` y `MedicationRequestDispenseRequest`.
- Sincronización de enums con ValueSets obligatorios como `CompositionStatus`, `CompositionAttestationMode`, `ReferencedItemCategory` y `RequestStatus`.
- Vinculación de autores y validadores de documentos combinando firmas de [`Practitioner`](https://hl7.org/fhir/R5/practitioner.html), [`Patient`](https://hl7.org/fhir/R5/patient.html), [`RelatedPerson`](https://hl7.org/fhir/R5/relatedperson.html) y [`Organization`](https://hl7.org/fhir/R5/organization.html).
