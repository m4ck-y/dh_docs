# Estado del Proyecto (LLM Context)

**Última actualización**: 2026-07-19

## Nuevos Proyectos

| Proyecto | Descripción | Stack |
| :--- | :--- | :--- |
| `dh_shared` | Paquete compartido de schemas FHIR R5 + utilidades | Python, Pydantic v2, SQLAlchemy, Beanie |
| `dh_fhir` | Descarga y gestión de recursos FHIR desde Jina AI | FastAPI, aiosqlite, httpx, Jinja2 |

## Hitos de Arquitectura Recientes
- **`dh_shared` creado**: Paquete instalable (`dh-shared`) con esquemas FHIR R5 en `schemas/shared/fhir/`. Sigue Screaming Architecture con `resources/`, `datatypes/`, `valueset/`, `extensibility/`.
- **`dh_fhir` creado**: Servicio FastAPI con DDD (`app/contexts/downloader/`). Descarga recursos FHIR via Jina AI, los almacena en SQLite y renderiza tablas.
- **FHIR Resources implementados (19 core)**: Patient, Practitioner, Organization, RelatedPerson, HealthcareService, PractitionerRole, AllergyIntolerance, FamilyMemberHistory, Condition, MedicationStatement, DocumentReference, Encounter, Location, Endpoint, ClinicalImpression, Procedure, Composition, MedicationRequest, Observation — todos heredan de `DomainResource`.
- **Recursos FHIR adicionales (15)**: Appointment, BodyStructure, CarePlan, CareTeam, Device, DeviceRequest, DiagnosticReport, EpisodeOfCare, Group, ImmunizationRecommendation, Medication, ObservationDefinition, Person, QuestionnaireResponse, ServiceRequest — total de recursos: 34.
- **FHIR Datatypes implementados (25 core)**: Address, Age, Annotation, Attachment, Availability, CodeableConcept, CodeableReference, Coding, ContactPoint, Dosage, Duration, Element, ExtendedContactDetail, HumanName, Identifier, Money, Period, Quantity, Range, Ratio, Reference, SampledData, SimpleQuantity, Timing, VirtualServiceDetail.
- **Tipos de soporte adicionales**: Meta, Narrative, RelatedArtifact, UsageContext, AddressType, AddressUse, IdentifierUse.
- **ValueSets implementados (110)**: Tabla detallada en seccion dedicada.
- **FHIR R5 .md descargados**: 142 archivos en `dh_fhir/files/` (recursos + value sets + datatypes + specs adicionales).
- **Arquitectura de herencia**: `Resource` → `DomainResource` → recursos específicos. Backbone elements como clases anidadas (ej: `HealthcareServiceEligibility(Element)`).
- **resourceType como computed_field**: `Resource` base ahora expone `resourceType` via `@computed_field` que retorna `type(self).__name__`. Eliminado de las 19 subclases. Previene errores de resourceType incorrecto.
- **Fix async blocking**: `jina_client.py` convertido de `urllib.request.urlopen` a `httpx.AsyncClient`. File I/O envuelto con `asyncio.to_thread`.
- **Frontend `dh_fhir`**: UI estilo terminal/TUI con VT323, colores neón, cursor parpadeante. Tabla ordenada A-Z por defecto.
- **Inter-Service Logging**: Todos los microservicios implementan logger dual (Python logging + httpx forwarding) segun ADR 006.
- **Renombres**: `dh_logger_tracer` → `dh_logger`, `dh_message_sender` → `dh_notify`. ROOT_PATH unificados: `/api/logger`, `/api/notify`.
- **Deploy plan**: Definido en docs (systemd `.service` files) y GitHub Actions (`deploy.yml` pendiente de creacion).
- **UUID v7**: Reemplazo de `uuid4` por `uuid7` (time-ordered) en `BaseModelMixin` (`dh_shared/src/dh_shared/base.py`) para indices B-tree eficientes. Libreria `uuid6`.

## Estado de los Servicios

| Servicio | Estado | Notas |
| :--- | :--- | :--- |
| `api_middleware` | 🟢 Activo | 10 sub-apps montadas (auth, iam, core, mfa, onboarding, health_monitoring, storage, admin, notify, logger). Puerto 8080 público. |
| `dh_auth` | 🟢 Activo | Stateless Auth, Login, Logout, Me, Refresh. UI retro terminal en `/`. Puerto 8081. |
| `dh_iam` | 🟢 Activo | RBAC completo: 32 endpoints. UI retro terminal en `/`. Puerto 8082. |
| `dh_core` | 🟢 Activo | CRUD completo Person + sub-entidades (27 endpoints). Soft-delete, UUID-only. UI retro terminal con 6 tabs. Puerto 8083. |
| `dh_mfa` | 🟢 Activo | OTP challenge (create, verify, resend). Naming `uuid_challenge` estandarizado. Puerto 8084. |
| `dh_onboarding` | 🟢 Activo | Flujo onboarding step-by-step. UI retro con 3 tabs (Waitlist, Onboarding, Legacy) y auto-avance. Puerto 8085. |
| `dh_health_monitoring` | 🟡 Pendiente | Directorio no existe aun. Monitoreo clinico planificado. |
| `dh_storage` | 🟢 Activo | 9 endpoints: documents, photos, files, config. Puerto 8087. Montado en gateway. |
| `dh_admin` | 🟢 Activo | Admin DB — drop/recreate schemas, seed. UI retro en `/`. Puerto 8088. Montado en gateway. |
| `dh_logger` (VitalTrace) | 🟡 Testing | Ingesta de logs, trazas, métricas. Puerto 8092. ROOT_PATH `/api/logger`. |
| `dh_notify` (PulseCore) | 🟡 Testing | OTP, Invites, Welcome messages. Puerto 8091. ROOT_PATH `/api/notify`. |
| `dh_fhir` | 🟢 Activo | Descarga recursos FHIR via Jina AI. SQLite, UI terminal. Puerto no asignado. |
| `dh_shared` | 🟢 Activo | Librería compartida — esquemas FHIR R5. `pip install dh-shared`. |

## Estado de Recursos FHIR en `dh_shared`

| Recurso | Estado | Notas |
| :--- | :--- | :--- |
| Patient | 🟢 Completo | 16 fields. resourceType heredado via computed_field |
| Practitioner | 🟢 Completo | + PractitionerQualification, PractitionerCommunication |
| Organization | 🟢 Completo | 14 fields |
| RelatedPerson | 🟢 Completo | + RelatedPersonCommunication |
| HealthcareService | 🟢 Completo | + HealthcareServiceEligibility. hoursOfOperation usa Availability |
| PractitionerRole | 🟢 Completo | 13 fields |
| AllergyIntolerance | 🟢 Completo | + AllergyIntoleranceParticipant, AllergyIntoleranceReaction |
| FamilyMemberHistory | 🟢 Completo | + FamilyMemberHistoryParticipant, FamilyMemberHistoryCondition, FamilyMemberHistoryProcedure |
| Condition | 🟢 Completo | + ConditionParticipant, ConditionStage. on-set/abatement choice types |
| MedicationStatement | 🟢 Completo | + MedicationStatementAdherence. Dosage datatype. effective[x] choice type |
| DocumentReference | 🟢 Completo | + DocumentReferenceAttester, DocumentReferenceRelatesTo, DocumentReferenceContent, DocumentReferenceContentProfile |
| Encounter | 🟢 Completo | + EncounterParticipant, EncounterReason, EncounterDiagnosis, EncounterAdmission, EncounterLocation |
| Location | 🟢 Completo | + LocationPosition backbone. EventStatus enum |
| Endpoint | 🟢 Completo | + EndpointPayload backbone |
| ClinicalImpression | 🟢 Completo | + ClinicalImpressionFinding backbone. effective[x] choice type |
| Procedure | 🟢 Completo | + ProcedurePerformer, ProcedureFocalDevice backbones. occurrence[x] (6), reported[x] choice types |
| Composition | 🟢 Completo | + CompositionAttester, CompositionEvent, CompositionSection (recursivo) backbones. `type` bindeado a `CodeableConcept[DocTypeCodes]` |
| MedicationRequest | 🟢 Completo | + MedicationRequestDispenseRequest, MedicationRequestSubstitution, MedicationRequestInitialFill, MedicationRequestDoseChange backbones |
| Observation | 🟢 Completo | + ObservationTriggeredBy, ObservationReferenceRange, ObservationComponent backbones. value[x] (13), effective[x] choice types |

## Recursos FHIR Adicionales

| Recurso | Estado | Notas |
| :--- | :--- | :--- |
| Appointment | 🟢 Completo | Agendamiento de citas |
| BodyStructure | 🟢 Completo | Estructura anatomicamente incluida/excluida |
| CarePlan | 🟢 Completo | Plan de cuidado |
| DeviceRequest | 🟢 Completo | Solicitud de dispositivo |
| EpisodeOfCare | 🟢 Completo | Episodio de atencion |
| ImmunizationRecommendation | 🟢 Completo | Recomendacion de inmunizacion |
| QuestionnaireResponse | 🟢 Completo | Respuestas a cuestionario |
| ServiceRequest | 🟢 Completo | Solicitud de servicio diagnostico o terapeutico |
| CareTeam | 🟢 Completo | + CareTeamParticipant backbone. coverage[x] choice type. Status via CareTeamStatus enum |
| Device | 🟢 Completo | + DeviceUdiCarrier, DeviceName, DeviceVersion, DeviceConformsTo, DeviceProperty backbones. value[x] 7-way choice |
| DiagnosticReport | 🟢 Completo | + DiagnosticReportMedia, DiagnosticReportSupportingInfo backbones. effective[x] choice. code bindeado a CodeableConcept[LOINCDiagnosticReportCodes] |
| Group | 🟢 Completo | + GroupCharacteristic, GroupMember backbones. value[x] 5-way choice. type bindeado a GroupType |
| Medication | 🟢 Completo | + MedicationIngredient, MedicationBatch backbones. strength[x] 3-way choice. CodeableReference for ingredient |
| ObservationDefinition | 🟢 Completo | + ObservationDefinitionQualifiedValue, ObservationDefinitionComponent backbones. versionAlgorithm[x] choice |
| Person | 🟢 Completo | + PersonCommunication, PersonLink backbones. deceased[x] choice. CodeableConcept[AllLanguages] |

## ValueSets FHIR Implementados (110 total)

### Core (55)

| ValueSet | Estado |
| :--- | :--- |
| allergy_intolerance_clinical_status, allergy_intolerance_verification_status | 🟢 |
| allergy_intolerance_type, allergy_intolerance_category, allergy_intolerance_criticality | 🟢 |
| composition_status | 🟢 |
| condition_clinical_status, condition_verification_status | 🟢 |
| condition_category, condition_severity | 🟢 |
| contact_point_system, contact_point_use | 🟢 |
| document_reference_status, document_relationship_type | 🟢 |
| encounter_status, encounter_location_status | 🟢 |
| family_history_status | 🟢 |
| marital_status | 🟢 |
| medication_statement_status | 🟢 |
| quantity_comparator | 🟢 |
| age_units | 🟢 |
| location_status, location_mode | 🟢 |
| endpoint_status, endpoint_environment | 🟢 |
| event_status | 🟢 |
| observation_status, observation_interpretation, triggered_by_type | 🟢 |
| medicationrequest_status, medicationrequest_intent, request_priority | 🟢 |
| medication_intended_performer_role, medicationrequest_course_of_therapy | 🟢 |
| list_order, list_empty_reason | 🟢 |
| data_absent_reason | 🟢 |
| name_use | 🟢 |
| organization_type | 🟢 |
| participation_role_type | 🟢 |
| patient_contact_relationship | 🟢 |
| patient_link | 🟢 |
| reaction_event_severity | 🟢 |

| care_team_status, device_name_type, device_status | 🟢 |
| diagnostic_report_status, group_membership_basis, group_type | 🟢 |
| identity_assurance_level, medication_status, observation_range_category | 🟢 |
| permitted_data_type, publication_status, udi_entry_type | 🟢 |

### Binding-specific / Extended (55)

| ValueSet | Estado |
| :--- | :--- |
| act_priority | 🟢 |
| act_substance_admin_substitution_code | 🟢 |
| admit_source | 🟢 |
| all_languages | 🟢 |
| appointment_recurrence_type | 🟢 |
| appointment_status | 🟢 |
| care_plan_intent | 🟢 |
| clinical_impression_change_pattern | 🟢 |
| clinical_impression_prognosis | 🟢 |
| clinical_impression_status_reason | 🟢 |
| composition_attestation_mode | 🟢 |
| condition_stage_type | 🟢 |
| contact_entity_type | 🟢 |
| days_of_week | 🟢 |
| discharge_disposition | 🟢 |
| encounter_class | 🟢 |
| encounter_diagnosis_use | 🟢 |
| encounter_diet | 🟢 |
| encounter_participant_type | 🟢 |
| encounter_reason_use | 🟢 |
| encounter_special_arrangements | 🟢 |
| encounter_special_courtesy | 🟢 |
| encounter_subject_status | 🟢 |
| encounter_type | 🟢 |
| endpoint_connection_type | 🟢 |
| endpoint_payload_type | 🟢 |
| episode_of_care_status | 🟢 |
| family_history_absent_reason | 🟢 |
| family_member | 🟢 |
| gender_administrative | 🟢 |
| location_characteristic | 🟢 |
| location_form | 🟢 |
| medication_request_category | 🟢 |
| medication_request_status_reason | 🟢 |
| medication_statement_adherence_code | 🟢 |
| observation_category | 🟢 |
| observation_referencerange_meaning | 🟢 |
| observation_referencerange_normal_value | 🟢 |
| participation_status | 🟢 |
| practitioner_role_enum | 🟢 |
| program | 🟢 |
| questionnaire_response_status | 🟢 |
| referenced_item_category | 🟢 |
| referral_method | 🟢 |
| related_artifact_type | 🟢 |
| request_intent | 🟢 |
| request_status | 🟢 |
| service_category | 🟢 |
| service_mode | 🟢 |
| service_provision_conditions | 🟢 |
| substance_admin_substitution_reason | 🟢 |
| week_of_month | 🟢 |
| device_availability_status | 🟢 |
| doc_type_codes | 🟢 |
| loinc_diagnostic_report_codes | 🟢 |

### Notas

- `address_type` y `address_use` estan implementados como enums en `datatypes/address_type.py` y `datatypes/address_use.py`, no en `valueset/`.
- `administrative_gender` se implementa como `gender_administrative.py` en `valueset/`.
- `identifier_use` esta implementado como clase interna en `datatypes/identifier.py` (no como archivo separado en `valueset/`).
- `identifier_type` aun no esta implementado; el campo `Identifier.type` usa `CodeableConcept` sin binding especifico en el catalogo actual.

## Datatypes FHIR Implementados

| Datatype | Estado | Notas |
| :--- | :--- | :--- |
| Address | 🟢 | |
| Age | 🟢 | Quantity-based. comparator usar QuantityComparator, unit usar AgeUnits enums |
| Annotation | 🟢 | |
| Attachment | 🟢 | model_validator en vez de field_validator |
| CodeableConcept / Coding | 🟢 | |
| CodeableReference | 🟢 | |
| ContactPoint | 🟢 | |
| Availability | 🟢 | + AvailabilityAvailableTime, AvailabilityNotAvailableTime backbones |
| Dosage | 🟢 | + DosageDoseAndRate. Timing, Ratio, SimpleQuantity, Duration tipados |
| Duration | 🟢 | Subclase de Quantity |
| Ratio | 🟢 | numerator/denominator Quantity |
| SampledData | 🟢 | origin, period, dimensions requeridos |
| SimpleQuantity | 🟢 | Subclase de Quantity (sin comparator) |
| Timing | 🟢 | + TimingRepeat backbone. boundsDuration, boundsRange tipados |
| VirtualServiceDetail | 🟢 | + channelType, addressUrl, addressString |
| Element | 🟢 | |
| ExtendedContactDetail | 🟢 | Ubicado en `extensibility/extended_contact_detail.py` |
| HumanName | 🟢 | |
| Identifier | 🟢 | Contiene `IdentifierUse` inline |
| Money | 🟢 | |
| Period | 🟢 | validator start <= end |
| Quantity | 🟢 | comparator usar QuantityComparator enum |
| Range | 🟢 | low/high como Quantity |
| Reference | 🟢 | |

## Tipos de Soporte Adicionales

| Tipo | Ubicacion | Notas |
| :--- | :--- | :--- |
| Meta | `datatypes/meta.py` | Metadata estandar de FHIR |
| Narrative | `datatypes/narrative.py` | Texto narrativo XHTML |
| RelatedArtifact | `datatypes/related_artifact.py` | Relacion entre recursos (cite, derive, etc.) |
| UsageContext | `datatypes/usage_context.py` | Contexto de uso (type + value) |
| Extension | `extensibility/extension.py` | Elemento base de extensibilidad FHIR |
| ContactDetail | `metadata_fields/contact_detail.py` | Contacto generico para recursos metadata |
| AddressType | `datatypes/address_type.py` | Enum usado por `Address` |
| AddressUse | `datatypes/address_use.py` | Enum usado por `Address` |


## Correcciones Recientes

| Issue | Archivo | Fix |
| :--- | :--- | :--- |
| Diagrama ASCII no Mermaid | `dh_fhir/docs/clinic_history.md`, `dh_shared/README.md`, `dh_shared/src/dh_shared/testui/README.md` | Migrados a bloques Mermaid |
| AGENTS.md FHIR en español con emojis | `dh_shared/src/dh_shared/schemas/shared/fhir/AGENTS.md` | Traducido a inglés y removidos emojis decorativos |
| Documentación faltante FHIR | `dh_fhir/README.md`, `dh_shared/docs/fhir_schemas.md` | Creados README del servicio y docs de schemas FHIR |
| Proceso faltante FHIR | `docs/decisions/036-fhir-r5-adoption.md`, `docs/tasks/TASK-014-dh-fhir-shared-schemas/README.md` | Creados ADR y TASK de seguimiento |
| Sin docstring | `address_type.py` | Agregado |
| Fields sin `Field()` | `identifier.py`, `human_name.py`, `address.py`, `contact_point.py` | Envueltos |
| `resourceType` sin description | `patient.py`, `practitioner.py`, `organization.py`, `related_person.py` | Agregado `Field(description=...)` |
| Docstring incompleto | `marital_status.py` | Corregido desc + ValueSet label |
| Docstring sin ValueSet label | `patient_contact_relationship.py` | Agregado |
| `field_validator` ↔ `model_validator` | `attachment.py` | Cambiado |
| Dead code | `code.py` | Eliminado |
| Docstring sin `Rule:` section | `patient.py`, `practitioner.py` | Agregado |
| Docstring con tabla/rule incorrecta | `base.py`, `element.py` | Corregido |
| Typo filename | `ornanization_type.py` → `organization_type.py` | Renombrado |
| `resourceType` en cada recurso | 27 recursos | Migrado a `@computed_field` en `Resource` base, eliminado de subclases |
| CodeableConcept sin binding (ClinicalImpression) | clinical_impression.py | Agregados enums clinical_impression_change_pattern, clinical_impression_prognosis + CodeableConcept[Enum] en changePattern, prognosisCodeableConcept |
| CodeableConcept sin binding (Observation) | observation.py | Agregados enum observation_category, data_absent_reason, observation_interpretation. CodeableConcept[Enum] en category, dataAbsentReason, interpretation (root+component). Fix `type` a TriggeredByType enum directo |
| CodeableConcept sin binding (Encounter) | encounter.py | Agregados 5 enums: encounter_participant_type, encounter_diagnosis_use, admit_source, special_arrangements, special_courtesy. Fields actualizados: participant.type, diagnosis.use, admitSource, specialArrangement, specialCourtesy |
| STATUS.md incoherente | `docs/STATUS.md` | Actualizados conteos: 27 recursos, 25+ datatypes, 95 valuesets, 142 specs .md; corregidos paths y servicios inexistentes |
| README en espanol fuera de docs/ | `dh_fhir/app/contexts/downloader/README.md` | Traducido a ingles y migrado diagrama ASCII a Mermaid |
| Docs basura/servicios inexistentes | `docs/ARCHITECTURE_OVERVIEW.md`, `docs/db/service_database_access_matrix.md`, `docs/architecture/diagrama_arquitectura.md` | Eliminados `dh_clinical` y `dh_seeder` como activos; corregidos `app_auth`/`app_onboarding`/`app_health_monitoring`/`app_questionnaire` a `dh_*` |
| Nombres de servicios obsoletos | `docs/decisions/006-inter-service-logging-standard.md`, `docs/tasks/TASK-013/README.md`, `docs/tasks/TASK-014/progress/2026-07-18.md`, `docs/reports/2026-04-21_FEATURE_integracion-middleware-contrato.md` | `logger_tracer_service` → `dh_logger`, `create_message_sender()` → `create_notify()`, `create_logger_tracer()` → `create_logger()`, `dh_expedient` → `dh_storage` |
| Estados de tasks contradictorios | `docs/tasks/TASK-001/README.md`, `TASK-003/README.md`, `TASK-004/README.md`, `TASK-007/README.md` | TASK-001 marcado `superseded`, TASK-003 y TASK-007 `completed`, TASK-004 objetivos chequeados |
| Links rotos en tasks | 13 tasks con `planning/`, `progress/` o `artifacts/` faltantes | Creados `README.md` en todos los subdirectorios enlazados |
| Ideas/ borradores sin estado | `docs/ideas/propuesta-001-auth.md`, `docs/ideas/documents_expedient/*.md`, `docs/ideas/template-migracion.md`, `docs/ideas/measurements.md` | Marcados como SUPERSEDED/ARCHIVADO/BORRADOR; removidos emojis decorativos |
| Archivo muerto | `docs/management/1_onboarding/0.overview.md` | Eliminado |
| Codigo inconsistente con ADR 005 | `dh_logger/app/main.py`, `dh_logger/pyproject.toml` | Reemplazado `motor` por `pymongo.AsyncMongoClient`; eliminada dependencia `motor` |
| Codigo inconsistente con ADR 005 | `other_projects/app_health_monitoring/backend/app/main.py` | Reemplazado `@app.on_event("startup")` por `lifespan` context manager |
| Recursos FHIR faltantes (gap analysis) | `docs/research/fhir-gap-analysis.md` | Identificados 7 recursos faltantes, 1 partial, 1 binding gap |
| CareTeam no implementado | `resources/care_team.py` | Creado con CareTeamParticipant backbone, coverage[x] choice, CareTeamStatus enum |
| Device no implementado | `resources/device.py` | Creado con 5 backbones, value[x] 7-way choice, 4 enums (device_status, device_name_type, udi_entry_type, device_availability_status) |
| DiagnosticReport no implementado | `resources/diagnostic_report.py` | Creado con DiagnosticReportMedia/SupportingInfo backbones, effective[x] choice, DiagnosticReportStatus + LOINCDiagnosticReportCodes enums |
| Group no implementado | `resources/group.py` | Creado con GroupCharacteristic/Member backbones, value[x] 5-way, GroupType + GroupMembershipBasis enums |
| Medication no implementado | `resources/medication.py` | Creado con MedicationIngredient/Batch backbones, strength[x] 3-way, MedicationStatusCodes enum |
| ObservationDefinition no implementado | `resources/observation_definition.py` | Creado con QualifiedValue/Component backbones, versionAlgorithm[x] choice, 3 enums |
| Person no implementado | `resources/person.py` | Creado con PersonCommunication/Link backbones, deceased[x] choice, IdentityAssuranceLevel + AllLanguages enums |
| MedicationRequest backbones como `Any` | `resources/medication_request.py` | Reemplazados `initialFill` y `doseChange` de `Any` a clases backbones tipadas |
| Composition.type sin binding | `resources/composition.py` | Agregado `CodeableConcept[DocTypeCodes]` para el binding Preferred a FHIRDocumentTypeCodes |
| Circular import preexistente | `resources/patient.py` ↔ `resources/related_person.py` | Identificado pero no corregido (pre-existente). model_rebuild agregado en __init__.py |
| Sin dependencias Python | entorno | Verificacion de runtime no posible (no pip, no sqlalchemy). AST parse exitoso en 9/9 archivos |

## Objetivos Inmediatos

### Completados (Fase 1: Binding Audit + Docs Cleanup)
1. ✅ ~~Implementar datatypes faltantes~~ (Timing, Ratio, SimpleQuantity, Duration, SampledData, Availability, VirtualServiceDetail).
2. ✅ ~~Unificar prefijo URL en docstrings~~ (Source: en attachment.py, human_name.py, period.py).
3. ✅ ~~Agregar property `definition` a enums~~ (age_units, gender_administrative, organization_type, patient_contact_relationship, patient_link, contact_entity_type).
4. ✅ ~~Verificar importabilidad desde un solo import~~ (`__init__.py` en resources/).
5. ✅ ~~Migrar `resourceType` a `computed_field` en base `Resource`~~ (Eliminado de 27 subclases).
6. ✅ ~~Binding audit: ClinicalImpression + reglas AGENTS.md~~.
7. ✅ ~~Observation bindings~~ (5 enums, 6 fields actualizados).
8. ✅ ~~Encounter bindings~~ (5 enums, 5 fields actualizados).
9. ✅ ~~Batch bindings restantes~~ (15 enums, 14 resources actualizados).
10. ✅ ~~Traducir docs en espanol fuera de docs/~~ (dh_fhir/app/contexts/downloader/README.md).
11. ✅ ~~Limpiar docs obsoletos~~ (ARCHITECTURE_OVERVIEW.md, service_database_access_matrix.md, diagrama_arquitectura.md, ADR 006, TASK-013/014, reports, ideas/).
12. ✅ ~~Arreglar codigo deprecated~~ (motor → pymongo.AsyncMongoClient, @app.on_event → lifespan).
13. ✅ ~~Identificar gaps FHIR~~ (7 missing resources, 1 partial, 1 binding gap).

### Activos (Fase 2: FHIR Resource Parity)
1. ✅ ~~Implementar CareTeam~~ (CareTeam + CareTeamStatus enum).
2. ✅ ~~Implementar Device~~ (Device + 4 enums + 5 backbones).
3. ✅ ~~Implementar DiagnosticReport~~ (DiagnosticReport + 2 enums + 2 backbones).
4. ✅ ~~Implementar Group~~ (Group + 2 enums + 2 backbones).
5. ✅ ~~Implementar Medication~~ (Medication + 1 enum + 2 backbones).
6. ✅ ~~Implementar ObservationDefinition~~ (ObservationDefinition + 3 enums + 2 backbones).
7. ✅ ~~Implementar Person~~ (Person + 2 enums + 2 backbones).
8. ✅ ~~Fix MedicationRequest backbones~~ (initialFill, doseChange tipados).
9. ✅ ~~Fix Composition.type binding~~ (CodeableConcept[DocTypeCodes]).

### Proximos (Fase 3)
1. ✅ ~~Agregar `model_rebuild` para los 7 nuevos recursos en `__init__.py`~~.
2. Verificar importabilidad con `from dh_shared.schemas.shared.fhir.resources import *` (bloqueado: no pip/sqlalchemy en entorno actual).
3. Ejecutar suite de tests si existe (bloqueado: dependencias no instalables).
4. Continuar analisis de gaps: revisar resources existentes para verificar que todos los `CodeableConcept` fields sigan las reglas de binding de AGENTS.md.
5. Resolver circular import entre `patient.py` y `related_person.py`.

## ADRs Recientes

| ADR | Título |
| :--- | :--- |
| ADR 036 | Adopcion de FHIR R5 como Estandar de Interoperabilidad Clinica |
| ADR 006 | Inter-Service Logging Standard — logger dual (Python logging + httpx) |
| ADR 008 | Datetime UTC Standard — `datetime.now(timezone.utc)`, `DateTime(timezone=True)` |
| ADR 010 | Estrategia de IDs — convencion estricta `uuid_` / `id_` sin sufijos |
| ADR 024 | UUIDs en API publica — alineado con ADR 010 |
| ADR 026 | Resolucion local del `id` interno post-respuesta de microservicio |
| ADR 027 | API Middleware — enlace a Test UI de cada microservicio |
| ADR 029 | Sub-objetos en DTOs — agrupacion semantica sin prefijos redundantes |
| ADR 030 | init_schemas — inicializacion centralizada de schemas (reemplaza sync_schemas) |
| ADR 031 | Configuracion baseline para microservicios — ROOT_PATH, CORS, checklist |
| ADR 032 | Politica de emojis como indicadores de estado — 🟢🟡🔴 solo tres colores |
| ADR 033 | Docstrings Swagger — templates y placeholders para `description=__doc__` |
| ADR 034 | Entity-UUID Path — GET/PATCH/DELETE con solo UUID de entidad, no parent UUID |
| ADR 035 | API Path Format — prohibido trailing slash en endpoints |

## Deuda Tecnica Conocida

### Estandarizacion de idioma y emojis (legacy)

| Issue | Ubicacion | Regla no aplicada |
| :--- | :--- | :--- |
| Archivos `.md` en espanol fuera de `docs/` | 87 archivos: `other_projects/app_questionnaire/`, `other_projects/app_health_monitoring/`, `backend/template_backend_python/`, `dh_logger/`, `dh_onboarding/`, `dh_notify/`, `LLM_STUDIO.md` | `AGENTS.md` y `.agents/rules/WRITING.md`: todo fuera de `docs/` debe estar en ingles. |
| Archivos `.md` en ingles dentro de `docs/` | 14 archivos: `docs/decisions/019-*.md`, `020-*.md`, `022-*.md`, `023-*.md`, `docs/historial_clinico/*.md`, `docs/management/1_onboarding_legacy/README.md`, `docs/ideas/measurements.md`, `docs/db/postgres/organizations/data_dictionary/*.md`, `docs/tasks/TASK-007-dh-storage/planning/*.md` | `.agents/rules/WRITING.md` y `.agents/rules/DOCS_PROJECT_STRUCTURE.md`: todo dentro de `docs/` debe estar en espanol. |
| Emojis decorativos en `.md` | 77 archivos (5 dentro de `docs/`, 72 fuera de `docs/`) | `AGENTS.md` y ADR 032: emojis decorativos prohibidos; solo permitidos `🟢`, `🟡`, `🔴` como indicadores de estado. |

**Nota**: Estos archivos son legacy. No impactan funcionalidad. Se corregiran solo cuando se refactoricen o se active el contexto de esos modulos. No se creara task adicional.

---

*Este documento es la fuente de verdad para el contexto de la IA.*
