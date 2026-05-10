---
type: task
id: TASK-009
title: "Microservicio de Identity & Access Management (dh_iam)"
status: completed
priority: high
created: "2026-04-26"
started: "2026-05-01"
completed: "2026-05-02"
tags: ["iam", "rbac", "tenants", "permissions"]
---

# TASK-009: Microservicio de Identity & Access Management (dh_iam)

## Descripcion
"Cerebro" de autorizacion del sistema. `dh_iam` gestiona quien puede hacer que (RBAC) y en que contexto (Tenants/Memberships).

## Objetivos cumplidos
- [x] Inicializar el repositorio `dh_iam` con Screaming Architecture.
- [x] **Gestion de Tenants**: CRUD de organizaciones (SYSTEM y COMPANY).
- [x] **Gestion de Recursos y Operaciones**: Catalogos globales para componer permisos.
- [x] **Gestion de Permisos**: Catalogo de permisos (recurso:operacion) con auto-generacion de key. Toggle activate/deactivate.
- [x] **Gestion de Roles**: CRUD de roles por tenant con asignacion de permisos via UUIDs.
- [x] **Gestion de Memberships**: CRUD de vinculos persona-tenant con asignacion de roles via UUIDs.
- [x] **API de Contexto para Auth**: `GET /v1/iam/context/{person_uuid}` devuelve roles + permisos agregados.
- [x] **32 endpoints** con paginacion, `ApiResponseSingle`/`ApiResponsePaginated`, UUIDs en API publica.
- [x] **Seeders**: Datos por defecto (tenant SYSTEM, 11 resources, 6 operations, permisos, admin role).
- [x] **Static Test UI**: Admin panel retro terminal en `GET /` con membership manager, permission generator.
- [x] **Dual logger**: ServiceLogger con forward asincrono a VitalTrace.
- [x] **Documentacion**: `ENDPOINTS.md`, `app/static/README.md`.

## Pendiente (futuro)
- Conexion real HTTP entre `dh_auth` y `dh_iam` (endpoint context).
- Integracion con `dh_onboarding` para membresias de paciente.
- Integracion con `dh_organizations` para membresias de empleado.
- Asignacion de permisos a roles desde la UI.
- Validacion RBAC en `api_middleware`.
