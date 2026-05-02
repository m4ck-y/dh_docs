---
type: task
id: TASK-011
title: "Microservicio dh_core — Maestro de Personas"
status: completed
priority: high
created: "2026-04-26"
started: "2026-04-26"
completed: "2026-05-02"
tags: [dh_core, people, postgres, sqlalchemy, fastapi]
---

# TASK-011: Microservicio dh_core — Maestro de Personas

## Descripcion

`dh_core` es el dueno exclusivo del schema `people` en PostgreSQL. Expone APIs para que otros servicios creen y actualicen personas sin acceso directo a la DB.

## Regla de Cross-Service
Los schemas `auth` y `expedient` referencian personas via `person_uuid UUID` (sin FK constraint).

## Objetivos cumplidos

- [x] Estructura base: FastAPI + Screaming Architecture + hexagonal.
- [x] Modelos SQLAlchemy: person, email, phone, birth, legal_info, personal_identifier, address, social_platform, social_links, emergency_contact.
- [x] `POST /v1/people/persons` — crea person + email + phone + birth + legal_info + personal_identifier.
- [x] `GET /v1/people/persons/{uuid_person}` — lectura de perfil.
- [x] `PATCH /v1/people/persons/{uuid_person}/status` — actualiza verification_status.
- [x] `GET /v1/people/persons/check-exists` — por email o CURP.
- [x] `POST/GET /v1/people/persons/{uuid}/emails` — gestion de emails.
- [x] `POST/GET /v1/people/persons/{uuid}/phones` — gestion de telefonos.
- [x] `POST/GET /v1/people/persons/{uuid}/identifiers` — identificadores personales (CURP, RFC, etc.).
- [x] `POST/GET /v1/people/persons/{uuid}/emergency-contacts` — contactos de emergencia.
- [x] VitalTrace logging en todas las acciones.
- [x] UUID-only API (ADR 024), ApiResponseSingle/Paginated (ADR 009).
- [x] Static test UI con tabs: PERSON, CONTACT, IDENTITY, SOCIAL (ADR 025).
- [x] ENDPOINTS.md, app/static/README.md.
- [x] .env.example, pyproject.toml con dependencias completas.

## Pendiente

- Contexto `relationships` — vinculos entre personas (familiar, tutor, responsable).
- Migrations con Alembic.
- Endpoints de actualizacion (PATCH) para datos de contacto e identificadores.
