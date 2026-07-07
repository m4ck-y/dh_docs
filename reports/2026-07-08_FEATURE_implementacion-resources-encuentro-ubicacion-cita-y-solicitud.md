**Proyecto o Apartado:** Core Domain / dh_shared / FHIR Encuentros y Planificación

**Título de la actividad o tarea:** Implementación de Esquemas Pydantic para Encounter, Location, Endpoint, Appointment y ServiceRequest

**Descripción de la actividad o tarea:**
Se diseñaron e implementaron los esquemas de validación Pydantic para los recursos de infraestructura y gestión de flujo de pacientes **Encounter**, **Location**, **Endpoint**, **Appointment** y **ServiceRequest** en la librería compartida de schemas `dh_shared`. Bajo el estándar HL7 FHIR R5, estos recursos estructuran la programación de consultas médicas, el registro físico/técnico del espacio clínico, el historial de visitas del paciente y las solicitudes de servicios clínicos externos.

- **`Encounter`** modela la interacción clínica concreta entre el paciente y los proveedores de salud. Registra participantes, motivos de consulta, diagnósticos asociados (`EncounterDiagnosis`), detalles de admisión e internación (`EncounterAdmission`) y el historial de ubicaciones físicas del paciente.
- **`Location`** representa el espacio físico donde se prestan los servicios médicos (hospitales, consultorios, pasillos, camas), detallando su estado operativo, tipo físico e información de contacto.
- **`Endpoint`** define la interfaz técnica y de red que permite la conectividad e intercambio electrónico de datos entre servicios de salud.
- **`Appointment`** gestiona la planificación y reserva de espacios de tiempo para consultas, coordinando participantes directos (médicos, pacientes, salas) y sus estados de confirmación.
- **`ServiceRequest`** representa las solicitudes de procedimientos, análisis de laboratorio u otras intervenciones clínicas ordenadas por un profesional.

La disponibilidad de estos esquemas permite gestionar el flujo del paciente desde la solicitud del servicio hasta el cierre del encuentro clínico. La vinculación entre ubicaciones físicas (`Location`), puntos de conexión electrónica (`Endpoint`) y citas agendadas (`Appointment`) proporciona una trazabilidad completa de la experiencia de atención del paciente dentro y fuera de la institución de salud.

**Estado de la actividad o tarea:** Concluido

**Avances de la actividad (si lo requiere):**
- Creación de los esquemas en los archivos correspondientes en `dh_shared/src/dh_shared/schemas/shared/fhir/resources/`.
- Soporte para variables con palabras reservadas mediante aliases en Pydantic (como `class_` mapeado a `class` en `Encounter`).
- Vinculación a ValueSets oficiales de control de flujo como `EncounterStatus`, `EncounterLocationStatus`, `EncounterParticipantType` y `ActPriority`.
- Integración de soporte para telemedicina y consultas virtuales mediante el datatype `VirtualServiceDetail`.
