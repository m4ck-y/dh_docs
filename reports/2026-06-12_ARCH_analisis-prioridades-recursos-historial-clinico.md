**Proyecto o Apartado:** Core Domain / dh_fhir / Docs / Clinical History Roadmap

**Título de la actividad o tarea:** Análisis de Prioridades e Infraestructura de Recursos para el Historial Clínico FHIR R5

**Descripción de la actividad o tarea:**
Se realizó una investigación profunda sobre los estándares HL7 FHIR R5 con el fin de estructurar y priorizar el modelado de esquemas para el Historial Clínico Electrónico en Digital Hospital. El resultado de este análisis se documentó formalmente en `docs/clinic_history.md`, estableciendo la jerarquía técnica y la prioridad de implementación para los 12 recursos clínicos esenciales del sistema, organizados jerárquicamente alrededor del recurso central [`Patient`](https://hl7.org/fhir/R5/patient.html).

El modelo diseñado define las dependencias operativas y la cobertura funcional necesaria para los expedientes de salud longitudinales e interoperables. Se estructuró una jerarquía donde recursos como [`Condition`](https://hl7.org/fhir/R5/condition.html), [`AllergyIntolerance`](https://hl7.org/fhir/R5/allergyintolerance.html) y [`FamilyMemberHistory`](https://hl7.org/fhir/R5/familymemberhistory.html) dependen directamente del paciente, mientras que las mediciones ([`Observation`](https://hl7.org/fhir/R5/observation.html)), intervenciones ([`Procedure`](https://hl7.org/fhir/R5/procedure.html)), evaluaciones ([`ClinicalImpression`](https://hl7.org/fhir/R5/clinicalimpression.html)) y recetas ([`MedicationRequest`](https://hl7.org/fhir/R5/medicationrequest.html)) se supeditan al contexto transaccional de una visita o consulta ([`Encounter`](https://hl7.org/fhir/R5/encounter.html)). Esta arquitectura sienta las bases para el intercambio de datos clínicos y la interoperabilidad de las APIs de la plataforma.

La priorización del mapa de ruta se centró en mitigar los riesgos de acoplamiento de datos y asegurar un flujo lógico de desarrollo. Al establecer la centralidad del recurso `Patient`, se garantiza que todos los identificadores locales, referencias y relaciones clínicas cuenten con un nodo raíz bien definido desde el inicio. Esto reduce el impacto de refactorizaciones futuras en el modelo de base de datos relacional de la plataforma.

**Estado de la actividad o tarea:** Concluido

**Avances de la actividad (si lo requiere):**
- Redacción y consolidación de la estructura del expediente clínico en el archivo `dh_fhir/docs/clinic_history.md`.
- Definición de la jerarquía de recursos (Patient -> Encounter -> Sub-recursos) para estructurar el desarrollo incremental de schemas.
- Mapeo de cobertura funcional para 12 recursos principales del estándar FHIR R5 ([Patient](https://hl7.org/fhir/R5/patient.html), [FamilyMemberHistory](https://hl7.org/fhir/R5/familymemberhistory.html), [AllergyIntolerance](https://hl7.org/fhir/R5/allergyintolerance.html), [Condition](https://hl7.org/fhir/R5/condition.html), [Encounter](https://hl7.org/fhir/R5/encounter.html), [Observation](https://hl7.org/fhir/R5/observation.html), [Procedure](https://hl7.org/fhir/R5/procedure.html), [ClinicalImpression](https://hl7.org/fhir/R5/clinicalimpression.html), [MedicationRequest](https://hl7.org/fhir/R5/medicationrequest.html), [Composition](https://hl7.org/fhir/R5/composition.html), [MedicationStatement](https://hl7.org/fhir/R5/medicationstatement.html), [DocumentReference](https://hl7.org/fhir/R5/documentreference.html)).
- Identificación de los casos de uso prioritarios del negocio (EHR, EMR, APIs de interoperabilidad e intercambio de datos longitudinales).
