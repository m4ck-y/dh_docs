**Proyecto o Apartado:** Core Domain / dh_shared / FHIR Directorios y Coordinación de Cuidado

**Título de la actividad o tarea:** Implementación de Esquemas Pydantic para HealthcareService, PractitionerRole, CarePlan y EpisodeOfCare

**Descripción de la actividad o tarea:**
Se diseñaron e implementaron los esquemas de validación Pydantic para los recursos de administración y coordinación médica **[HealthcareService](https://hl7.org/fhir/R5/healthcareservice.html)**, **[PractitionerRole](https://hl7.org/fhir/R5/practitionerrole.html)**, **[CarePlan](https://hl7.org/fhir/R5/careplan.html)** y **[EpisodeOfCare](https://hl7.org/fhir/R5/episodeofcare.html)** en la librería compartida de schemas `dh_shared` bajo el estándar HL7 FHIR R5. Estos recursos permiten modelar la oferta de servicios institucionales, la asignación de profesionales a roles específicos y el seguimiento continuo de los planes de cuidado personalizados para cada paciente.

- **[`HealthcareService`](https://hl7.org/fhir/R5/healthcareservice.html)** modela los detalles de los servicios clínicos disponibles en ubicaciones específicas y ofrecidos por organizaciones de salud, gestionando categorías de especialidad y requisitos de elegibilidad.
- **[`PractitionerRole`](https://hl7.org/fhir/R5/practitionerrole.html)** asocia a un profesional médico ([`Practitioner`](https://hl7.org/fhir/R5/practitioner.html)) con una organización y roles específicos, definiendo sus especialidades y canales de comunicación técnica ([`Endpoint`](https://hl7.org/fhir/R5/endpoint.html)).
- **[`CarePlan`](https://hl7.org/fhir/R5/careplan.html)** describe la planificación e intención de los profesionales de la salud al proveer cuidado continuo al paciente, organizando las metas, actividades clínicas y diagnósticos relacionados.
- **[`EpisodeOfCare`](https://hl7.org/fhir/R5/episodeofcare.html)** representa la asociación temporal de responsabilidad asistencial entre el paciente y un proveedor, sirviendo de contenedor general bajo el cual ocurren los encuentros clínicos.

La integración de estos recursos sienta la infraestructura lógica para la coordinación del cuidado clínico y la gestión operativa en Digital Hospital. Al vincular los planes de cuidado ([`CarePlan`](https://hl7.org/fhir/R5/careplan.html)) con episodios de atención ([`EpisodeOfCare`](https://hl7.org/fhir/R5/episodeofcare.html)), se habilita el seguimiento de tratamientos a largo plazo y la asignación eficiente de responsabilidades asistenciales a los profesionales de la salud.

**Estado de la actividad o tarea:** Concluido

**Avances de la actividad (si lo requiere):**
- Creación de los archivos de recursos `healthcare_service.py`, `practitioner_role.py`, `care_plan.py` y `episode_of_care.py` en `dh_shared/src/dh_shared/schemas/shared/fhir/resources/`.
- Integración de referencias cruzadas tipadas entre los recursos mediante la propiedad [`Reference[Organization]`](https://hl7.org/fhir/R5/organization.html), [`Reference[Practitioner]`](https://hl7.org/fhir/R5/practitioner.html), [`Reference[Location]`](https://hl7.org/fhir/R5/location.html) y [`Reference[Patient]`](https://hl7.org/fhir/R5/patient.html).
- Implementación de sub-elementos complejos como `HealthcareServiceEligibility`, `CarePlanActivity`, `EpisodeOfCareStatusHistory`, `EpisodeOfCareReason` y `EpisodeOfCareDiagnosis`.
- Enlazado de enums de control de estado y categorías clínicas con los ValueSets correspondientes como `RequestStatus`, `CarePlanIntent`, `EpisodeOfCareStatus` y `PractitionerRoleEnum`.
