---
type: task
id: TASK-011
title: "Microservicio dh_core — Maestro de Personas"
status: in-progress
priority: high
created: "2026-04-26"
started: "2026-04-26"
completed: null
tags: [dh_core, people, postgres, sqlalchemy, fastapi]
---

# TASK-011: Microservicio dh_core — Maestro de Personas

## Descripción

`dh_core` es el dueño exclusivo del schema `people` en PostgreSQL. Expone APIs para que otros servicios (principalmente `dh_onboarding_back`) creen y actualicen personas sin acceso directo a la DB.

## Regla de Cross-Service
Los schemas `auth` y `expedient` referencian personas via `person_uuid UUID` (sin FK constraint). No existe FK cross-schema entre servicios.

## Objetivos — Fase 1 (lo mínimo para desbloquear onboarding)

- [x] Estructura base: FastAPI + Screaming Architecture + hexagonal.
- [x] Modelos SQLAlchemy: `person`, `email`, `phone`, `birth`, `legal_info`, `personal_identifier`, `address`.
- [x] `POST /v1/people/persons` — crea person + email + phone + birth + legal_info + personal_identifier en una transacción.
- [x] `POST /v1/people/persons/{id_person}/address` — crea address.
- [x] `PATCH /v1/people/persons/{id_person}/status` — actualiza `verification_status`.
- [x] VitalTrace logging en cada acción.
- [x] `.env.example`, `pyproject.toml` con dependencias completas.

## Objetivos — Fase 2 (backlog)

- [ ] `GET /v1/people/persons/{id_person}` — lectura de perfil completo.
- [ ] `PATCH /v1/people/persons/{id_person}` — actualización de datos personales.
- [ ] Contexto `relationships` — vínculos entre personas (familiar, tutor, responsable).
- [ ] Migrations con Alembic.
- [ ] Puerto oficial: 8040.

## 📜 Log de Cambios
- **2026-04-26**: Fase 1 implementada. Extraída desde `dh_onboarding_back` que antes escribía directamente en `people.*`.

## 🔗 Enlaces Rápidos
- [Plan de Ejecución](planning/README.md)
- [Registro de Progreso](progress/)
- [Artefactos](artifacts/)
- [ERD people](../../../db/postgres/people/erd.mmd)
- [Matriz de acceso](../../../db/service_database_access_matrix.md)
