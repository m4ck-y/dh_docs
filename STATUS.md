# Estado del Proyecto (LLM Context)

**Última actualización**: 2026-06-20

## Nuevos Proyectos

| Proyecto | Descripción | Stack |
| :--- | :--- | :--- |
| `dh_shared` | Paquete compartido de schemas FHIR R5 + utilidades | Python, Pydantic v2, SQLAlchemy, Beanie |
| `dh_fhir` | Descarga y gestión de recursos FHIR desde Jina AI | FastAPI, aiosqlite, httpx, Jinja2 |

## Hitos de Arquitectura Recientes
- **`dh_shared` creado**: Paquete instalable (`dh-shared`) con esquemas FHIR R5 en `schemas/shared/fhir/`. Sigue Screaming Architecture con `resources/`, `datatypes/`, `valueset/`, `extensibility/`.
- **`dh_fhir` creado**: Servicio FastAPI con DDD (`app/contexts/downloader/`). Descarga recursos FHIR via Jina AI, los almacena en SQLite y renderiza tablas.
- **FHIR Resources implementados**: Patient, Practitioner, Organization, RelatedPerson, HealthcareService, PractitionerRole, AllergyIntolerance, FamilyMemberHistory, Condition, MedicationStatement, DocumentReference, Encounter, Location, Endpoint, ClinicalImpression, Procedure, Composition, MedicationRequest, Observation — 19 resources total, todos heredan de `DomainResource`.
- **FHIR Datatypes implementados**: Address, Age, Annotation, Attachment, Availability, CodeableConcept, CodeableReference, Coding, ContactPoint, Dosage, Duration, Element, ExtendedContactDetail, HumanName, Identifier, Money, Period, Quantity, Range, Ratio, Reference, SampledData, SimpleQuantity, Timing, VirtualServiceDetail — **25 datatypes total**.
- **ValueSets implementados**: address_type, address_use, administrative_gender, allergy_intolerance_clinical_status, allergy_intolerance_verification_status, allergy_intolerance_type, allergy_intolerance_category, allergy_intolerance_criticality, composition_status, condition_category, condition_clinical_status, condition_severity, condition_verification_status, contact_point_system, contact_point_use, document_relationship_type, document_reference_status, encounter_location_status, encounter_status, family_history_status, gender_administrative, identifier_type, identifier_use, marital_status, medication_statement_status, name_use, organization_type, participation_role_type, patient_contact_relationship, patient_link_type, reaction_event_severity.
- **FHIR R5 .md descargados**: 72 archivos en `dh_fhir/files/` (recursos + value sets + datatypes).
- **Arquitectura de herencia**: `Resource` → `DomainResource` → recursos específicos. Backbone elements como clases anidadas (ej: `HealthcareServiceEligibility(Element)`).
- **resourceType como computed_field**: `Resource` base ahora expone `resourceType` via `@computed_field` que retorna `type(self).__name__`. Eliminado de las 19 subclases. Previene errores de resourceType incorrecto.
- **Fix async blocking**: `jina_client.py` convertido de `urllib.request.urlopen` a `httpx.AsyncClient`. File I/O envuelto con `asyncio.to_thread`.
- **Frontend `dh_fhir`**: UI estilo terminal/TUI con VT323, colores neón, cursor parpadeante. Tabla ordenada A-Z por defecto.
- **Inter-Service Logging**: Todos los microservicios implementan logger dual (Python logging + httpx forwarding) segun ADR 006.
- **Renombres**: `dh_logger_tracer` → `dh_logger`, `dh_message_sender` → `dh_notify`. ROOT_PATH unificados: `/api/logger`, `/api/notify`.
- **Deploy automático**: Plan systemd + GitHub Actions para todos los microservicios. `.service` files en `docs/`, workflows en `.github/workflows/deploy.yml`.
- **UUID v7**: Reemplazo de `uuid4` por `uuid7` (time-ordered) en `BaseModelMixin` para indices B-tree eficientes. Libreria `uuid6`.

## Estado de los Servicios

| Servicio | Estado | Notas |
| :--- | :--- | :--- |
| `api_middleware` | 🟢 Activo | 10 sub-apps montadas (auth, iam, core, mfa, onboarding, health_monitoring, storage, admin, notify, logger). Puerto 8080 público. |
| `dh_auth` | 🟢 Activo | Stateless Auth, Login, Logout, Me, Refresh. UI retro terminal en `/`. Puerto 8081. |
| `dh_iam` | 🟢 Activo | RBAC completo: 32 endpoints. UI retro terminal en `/`. Puerto 8082. |
| `dh_core` | 🟢 Activo | CRUD completo Person + sub-entidades (27 endpoints). Soft-delete, UUID-only. UI retro terminal con 6 tabs. Puerto 8083. |
| `dh_mfa` | 🟢 Activo | OTP challenge (create, verify, resend). Naming `uuid_challenge` estandarizado. Puerto 8084. |
| `dh_onboarding` | 🟢 Activo | Flujo onboarding step-by-step. UI retro con 3 tabs (Waitlist, Onboarding, Legacy) y auto-avance. Puerto 8085. |
| `dh_health_monitoring` | 🟢 Activo | Monitoreo clínico: mediciones, tipos, reportes. Puerto 8086. |
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
| Composition | 🟢 Completo | + CompositionAttester, CompositionEvent, CompositionSection (recursivo) backbones |
| MedicationRequest | 🟢 Completo | + MedicationRequestDispenseRequest, MedicationRequestSubstitution backbones |
| Observation | 🟢 Completo | + ObservationTriggeredBy, ObservationReferenceRange, ObservationComponent backbones. value[x] (13), effective[x] choice types |

## ValueSets FHIR Implementados (70 total)

| ValueSet | Estado |
| :--- | :--- |
| address_type, address_use | 🟢 |
| administrative_gender | 🟢 |
| allergy_intolerance_clinical_status, allergy_intolerance_verification_status | 🟢 |
| allergy_intolerance_type, allergy_intolerance_category, allergy_intolerance_criticality | 🟢 |
| composition_status | 🟢 |
| condition_clinical_status, condition_verification_status | 🟢 |
| condition_category, condition_severity | 🟢 |
| contact_point_system, contact_point_use | 🟢 |
| document_reference_status, document_relationship_type | 🟢 |
| encounter_status, encounter_location_status | 🟢 |
| family_history_status | 🟢 |
| identifier_type, identifier_use | 🟢 |
| marital_status | 🟢 |
| medication_statement_status | 🟢 |
| quantity_comparator | 🟢 |
| age_units | 🟢 |
| location_status, location_mode | 🟢 |
| endpoint_status, endpoint_environment | 🟢 |
| event_status | 🟢 |
| observation_status, observation_interpretation, observation_triggeredbytype | 🟢 |
| medicationrequest_status, medicationrequest_intent, request_priority | 🟢 |
| medication_intended_performer_role, medicationrequest_course_of_therapy | 🟢 |
| list_order, list_empty_reason | 🟢 |
| data_absent_reason | 🟢 |
| name_use | 🟢 |
| organization_type | 🟢 |
| participation_role_type | 🟢 |
| patient_contact_relationship | 🟢 |
| patient_link_type | 🟢 |
| reaction_event_severity | 🟢 |

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
| ExtendedContactDetail | 🟢 | |
| HumanName | 🟢 | |
| Identifier | 🟢 | |
| Money | 🟢 | |
| Period | 🟢 | validator start <= end |
| Quantity | 🟢 | comparator usar QuantityComparator enum |
| Range | 🟢 | low/high como Quantity |
| Reference | 🟢 | |


## Correcciones Recientes

| Issue | Archivo | Fix |
| :--- | :--- | :--- |
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
| `resourceType` en cada recurso | 19 recursos | Migrado a `@computed_field` en `Resource` base, eliminado de subclases |
| CodeableConcept sin binding (ClinicalImpression) | clinical_impression.py | Agregados enums clinical_impression_change_pattern, clinical_impression_prognosis + CodeableConcept[Enum] en changePattern, prognosisCodeableConcept |
| CodeableConcept sin binding (Observation) | observation.py | Agregados enum observation_category, data_absent_reason, observation_interpretation. CodeableConcept[Enum] en category, dataAbsentReason, interpretation (root+component). Fix `type` a TriggeredByType enum directo |
| CodeableConcept sin binding (Encounter) | encounter.py | Agregados 5 enums: encounter_participant_type, encounter_diagnosis_use, admit_source, special_arrangements, special_courtesy. Fields actualizados: participant.type, diagnosis.use, admitSource, specialArrangement, specialCourtesy |

## Objetivos Inmediatos

1. ~~Implementar datatypes faltantes~~ ✅ Completado (Timing, Ratio, SimpleQuantity, Duration, SampledData, Availability, VirtualServiceDetail).
2. ~~Unificar prefijo URL en docstrings~~ ✅ Completado (Source: en attachment.py, human_name.py, period.py).
3. ~~Agregar property `definition` a enums~~ ✅ Completado (age_units, gender_administrative, organization_type, patient_contact_relationship, patient_link, contact_entity_type).
4. ~~Verificar importabilidad desde un solo import~~ ✅ Completado (`__init__.py` en resources/).
5. ~~Migrar `resourceType` a `computed_field` en base `Resource`~~ ✅ Completado. Eliminado de 19 subclases.
6. ~~Binding audit: ClinicalImpression + reglas AGENTS.md~~ ✅ Completado.
7. ~~Observation bindings~~ ✅ Completado (5 enums, 6 fields actualizados).
8. ~~Encounter bindings~~ ✅ Completado (5 enums, 5 fields actualizados).
9. ~~Batch bindings restantes~~ ✅ Completado (15 enums, 14 resources actualizados).

## ADRs Recientes

| ADR | Título |
| :--- | :--- |
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

---

*Este documento es la fuente de verdad para el contexto de la IA.*
