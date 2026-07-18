---
type: task
id: TASK-001
title: "Migración de Módulo Auth y Estructura Base API Core"
status: superseded
priority: critical
created: "2026-04-10"
started: "2026-04-10"
completed: "2026-04-26"
tags: [auth, dh_core, migration]
---

# TASK-001: Migración de Módulo Auth y Estructura Base API Core

## Estado
**SUPERSEDED**. La estrategia cambio: en lugar de migrar auth a `dh_core`, se creo un microservicio independiente `dh_auth` (TASK-004). `dh_core` se enfoco exclusivamente en personas y relaciones sociales.

## Descripcion
Esta tarea consiste en establecer los cimientos de `dh_core` migrando la lógica de autenticación desde la plantilla `template_backend_python`. Se debe implementar bajo principios de Clean Architecture y DDD.

## Objetivos (no aplicados — task superseded)
- ~~Estructurar contextos en `dh_core` (person, account, security).~~ Objetivo original descartado; `dh_core` se redujo a dominio de personas.
- ~~Migrar lógica de JWT.~~ Descartado; JWT se implementó en `dh_auth` (TASK-004).
- ~~Implementar validación global (ADR-002).~~ No aplica tras la separación de `dh_auth`.
- ~~Configurar conectores para Multi-DB (ADR-003).~~ No aplica tras la separación de `dh_auth`.

## Resultado
- Auth no fue migrado a `dh_core`.
- Se extrajo `dh_auth` como servicio independiente (ver TASK-004).
- `dh_core` heredo solo el dominio de personas del template original.

## Enlaces Rapidos
- [Plan de Ejecución](planning/README.md)
- [Registro de Progreso](progress/)
- [Artefactos](artifacts/)
