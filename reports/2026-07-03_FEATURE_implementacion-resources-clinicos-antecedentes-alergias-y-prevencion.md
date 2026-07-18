**Proyecto o Apartado:** Core Domain / dh_shared / FHIR Perfil Clínico y Prevención

**Título de la actividad o tarea:** Implementación de Esquemas Pydantic para AllergyIntolerance, Condition, FamilyMemberHistory, ImmunizationRecommendation y QuestionnaireResponse

**Descripción de la actividad o tarea:**
Se implementaron los esquemas de validación Pydantic para los recursos clínicos centrales del paciente **[AllergyIntolerance](https://hl7.org/fhir/R5/allergyintolerance.html)**, **[Condition](https://hl7.org/fhir/R5/condition.html)**, **[FamilyMemberHistory](https://hl7.org/fhir/R5/familymemberhistory.html)**, **[ImmunizationRecommendation](https://hl7.org/fhir/R5/immunizationrecommendation.html)** y **[QuestionnaireResponse](https://hl7.org/fhir/R5/questionnaireresponse.html)** en la librería `dh_shared` siguiendo la especificación HL7 FHIR R5. Estos esquemas permiten capturar de forma estandarizada los antecedentes patológicos del paciente, sus alergias, la historia clínica hereditaria, las recomendaciones de vacunación vigentes y las respuestas a encuestas o cuestionarios de salud.

- **[`AllergyIntolerance`](https://hl7.org/fhir/R5/allergyintolerance.html)** registra el riesgo de reacciones adversas ante sustancias específicas (medicamentos, alimentos, ambientales), gestionando su estado clínico y la criticidad del riesgo. Se diseñó el sub-elemento `AllergyIntoleranceReaction` para detallar los eventos de exposición y sus manifestaciones.
- **[`Condition`](https://hl7.org/fhir/R5/condition.html)** modela problemas de salud, diagnósticos clínicos o enfermedades crónicas, asociando códigos de clasificación (como CIE-10/Snomed-CT) con estados clínicos y de verificación.
- **[`FamilyMemberHistory`](https://hl7.org/fhir/R5/familymemberhistory.html)** captura los antecedentes clínicos familiares detallando la relación de parentesco y las condiciones de salud diagnosticadas en los familiares consanguíneos.
- **[`ImmunizationRecommendation`](https://hl7.org/fhir/R5/immunizationrecommendation.html)** describe las recomendaciones del plan de inmunización (vacunas indicadas, dosis y calendarios de administración sugeridos).
- **[`QuestionnaireResponse`](https://hl7.org/fhir/R5/questionnaireresponse.html)** representa las respuestas proporcionadas por el paciente o personal clínico ante un cuestionario predefinido, facilitando la ingesta estructurada de datos de autoevaluación.

Este conjunto de esquemas constituye el núcleo del resumen clínico y la historia de salud longitudinal del paciente. La estructura diseñada asegura que las condiciones de salud y alergias estén vinculadas con sus respectivos ValueSets oficiales, permitiendo una clasificación interoperable (mediante códigos estándar como SNOMED-CT y CIE-10) que facilita la toma de decisiones clínicas automatizada.

**Estado de la actividad o tarea:** Concluido

**Avances de la actividad (si lo requiere):**
- Escritura e integración de los schemas en la estructura de `dh_shared/src/dh_shared/schemas/shared/fhir/resources/`.
- Implementación de validadores cruzados `@model_validator(mode="after")` para manejar los campos de elección libre (*choice types*) en eventos de inicio como `onset[x]` en `AllergyIntolerance` y `Condition`.
- Vinculación de los estados y estados de verificación con ValueSets obligatorios como `AllergyIntoleranceClinicalStatus`, `ConditionVerificationStatus` y `EpisodeOfCareStatus`.
- Soporte para referencias complejas asociando las condiciones clínicas a médicos ([`Practitioner`](https://hl7.org/fhir/R5/practitioner.html)), pacientes ([`Patient`](https://hl7.org/fhir/R5/patient.html)) y encuentros clínicos específicos ([`Encounter`](https://hl7.org/fhir/R5/encounter.html)).
