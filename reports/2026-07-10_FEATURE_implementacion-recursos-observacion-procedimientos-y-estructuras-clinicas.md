**Proyecto o Apartado:** Core Domain / dh_shared / FHIR Hallazgos y Procedimientos Clínicos

**Título de la actividad o tarea:** Implementación de Esquemas Pydantic para Observation, Procedure, ClinicalImpression, DeviceRequest y BodyStructure

**Descripción de la actividad o tarea:**
Se diseñaron e implementaron los esquemas de validación Pydantic para los recursos de registro clínico directo **Observation**, **Procedure**, **ClinicalImpression**, **DeviceRequest** y **BodyStructure** en la librería compartida `dh_shared` bajo el estándar HL7 FHIR R5. Estos esquemas permiten estructurar el registro de mediciones físicas, resultados de laboratorio, intervenciones terapéuticas, evaluaciones globales del estado clínico del paciente, solicitudes de dispositivos de asistencia e identificación anatómica de estructuras corporales.

- **`Observation`** modela hallazgos clínicos como signos vitales, resultados de laboratorio y observaciones subjetivas de los clínicos. Soporta estructuras anidadas para componentes de medición múltiple y valores de rango clínico de referencia.
- **`Procedure`** registra acciones e intervenciones quirúrgicas, terapéuticas o diagnósticas aplicadas a los pacientes, vinculando el rol de los participantes e identificando complicaciones.
- **`ClinicalImpression`** representa la evaluación integral del estado clínico de un paciente en un momento específico, agrupando problemas, hallazgos (`ClinicalImpressionFinding`) y prognósticos esperados.
- **`DeviceRequest`** modela la solicitud e indicación de uso de un dispositivo médico de asistencia o soporte vital para un paciente.
- **`BodyStructure`** representa los detalles específicos de una parte o estructura anatómica del cuerpo que es objeto de diagnóstico o intervención.

Estos esquemas estructuran los datos más dinámicos y de mayor volumen en el ecosistema de salud, como las mediciones de signos vitales, resultados de laboratorio y las intervenciones médicas. La definición de relaciones anatómicas mediante `BodyStructure` e indicaciones de equipamiento médico a través de `DeviceRequest` complementa el registro clínico, permitiendo análisis avanzados y auditorías de calidad asistencial.

**Estado de la actividad o tarea:** Concluido

**Avances de la actividad (si lo requiere):**
- Escritura y registro de los schemas en `dh_shared/src/dh_shared/schemas/shared/fhir/resources/`.
- Soporte para estructuras anidadas como `ObservationComponent`, `ObservationReferenceRange`, `ProcedurePerformer`, `ClinicalImpressionFinding` e `ClinicalImpression`.
- Validación de campos selectivos (*choice types*) para fechas o períodos clínicos eficaces mediante decoradores `@model_validator(mode="after")`.
- Enlace con ValueSets específicos como `EventStatus`, `ClinicalImpressionChangePattern`, `ClinicalImpressionPrognosis` y `ClinicalImpressionStatusReason`.
