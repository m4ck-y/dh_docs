---
type: task
id: TASK-015
title: "Adaptacion FHIR: persistencia hibrida PostgreSQL + MongoDB"
status: backlog
priority: high
created: "2026-07-19"
started: null
completed: null
tags: ["fhir", "mongodb", "postgresql", "persistencia", "beanie", "rbac"]
---

# TASK-015: Adaptacion FHIR — persistencia hibrida PostgreSQL + MongoDB

## Descripcion

Implementar la estrategia de persistencia hibrida para recursos FHIR R5, donde PostgreSQL mantiene el modelo relacional transaccional existente y MongoDB almacena los documentos FHIR completos en formato JSON validados con los schemas Pydantic de `dh_shared`. Ambos almacenes se vinculan mediante el UUID dual ya establecido (ADR 010).

El objetivo es lograr FHIR compliance sin reestructurar las ~68 tablas PostgreSQL existentes, usando MongoDB como almacen documental nativo para los recursos FHIR, aprovechando la infraestructura Beanie ODM ya presente en el stack (ADR 003, ADR 005).

La migracion se realiza por microservicio en fases incrementales: RBAC primero como precondicion de seguridad, luego Organization, Patient, Practitioner, y finalmente recursos clinicos.

## Objetivos

### Fase 0 — Infraestructura Base
- [ ] Crear modulo `dh_shared/mappings/` con utilities de transformacion PG → FHIR.
- [ ] Definir documentos Beanie base para recursos FHIR en `dh_shared/schemas/shared/fhir/documents/`.
- [ ] Implementar patron de sync service (hook post-commit PG → escritura MongoDB).
- [ ] Registrar documento de arquitectura de sincronizacion en `planning/`.

### Fase 1 — RBAC + Admin (precondicion de seguridad)
- [ ] Crear seed de usuario administrador con roles y permisos completos.
- [ ] Verificar que el middleware `api_middleware` respeta tokens y permisos RBAC.
- [ ] Testear endpoint protegido con admin antes de exponer datos clinicos.
- [ ] Documentar matriz de permisos en `planning/rbac-permission-matrix.md`.

### Fase 2 — Organization (Company → FHIR Organization)
- [ ] Implementar mapping `org.company` → `Organization` (FHIR).
- [ ] Crear `OrganizationDocument` (Beanie) y registrar en `init_beanie()`.
- [ ] Implementar sync service: post-commit hook en operaciones CRUD de `company`.
- [ ] Exponer endpoint FHIR `GET /fhir/Organization/{uuid}` en `api_middleware`.
- [ ] Agregar cobertura de tests unitarios para mapping y sync.

### Fase 3 — Patient (Person → FHIR Patient)
- [ ] Implementar mapping `people.person + birth + legal_info + sociocultural + profile` → `Patient`.
- [ ] Crear `PatientDocument` (Beanie) y registrar en `init_beanie()`.
- [ ] Implementar sync service: post-commit hook en operaciones CRUD de `person`.
- [ ] Exponer endpoints FHIR `GET/POST /fhir/Patient/{uuid}` en `api_middleware`.
- [ ] Agregar cobertura de tests unitarios para mapping y sync.

### Fase 4 — Practitioner (Person + Employee → FHIR Practitioner)
- [ ] Implementar mapping `people.person + org.employee` → `Practitioner`.
- [ ] Crear `PractitionerDocument` (Beanie) y registrar en `init_beanie()`.
- [ ] Implementar sync service: post-commit hook en operaciones CRUD de `employee`.
- [ ] Exponer endpoints FHIR `GET/POST /fhir/Practitioner/{uuid}` en `api_middleware`.
- [ ] Agregar cobertura de tests unitarios para mapping y sync.

### Fases posteriores (backlog)
- [ ] HealthcareService, PractitionerRole, RelatedPerson, Location, Endpoint.
- [ ] Condition, AllergyIntolerance, Observation, Procedure, Encounter.
- [ ] Medication, MedicationRequest, MedicationStatement.
- [ ] Questionnaire, QuestionnaireResponse (ya aislados en `app_questionnaire`).

## Enlaces Rapidos

- [Plan de Ejecucion](planning/README.md)
- [Registro de Progreso](progress/)
- [Artefactos](artifacts/)
- [ADR 003: Polyglot Persistence](../../decisions/003-estrategia-multi-base-de-datos.md)
- [ADR 005: MongoDB Driver + FastAPI Lifespan](../../decisions/005-mongodb-driver-and-fastapi-lifespan.md)
- [ADR 010: Database ID Strategy (UUID dual)](../../decisions/010-database-id-strategy.md)
- [ADR 036: Adopcion FHIR R5](../../decisions/036-fhir-r5-adoption.md)
- [TASK-014: Schemas FHIR R5 en dh_shared](../TASK-014-dh-fhir-shared-schemas/README.md)

## Notas

- Cada fase es autonoma: se puede mergear, testear y desplegar sin esperar a las demas.
- La Fase 0 (infraestructura) es la unica dependencia del resto.
- MongoDB ya esta operativo en `dh_onboarding` (waitlist) y `dh_logger` (logs/traces).
- Los schemas Pydantic FHIR en `dh_shared` sirven como capa de validacion para los documentos Beanie.
- El sync service debe ser silencioso ante fallos (mismo principio que el dual logger — ADR 006).
- No se requiere ADR adicional: ADR 003 (polyglot), ADR 005 (Beanie lifespan), y ADR 036 (FHIR) ya cubren la decision de arquitectura.
