---
type: task
id: TASK-001
title: "Migración de Módulo Auth y Estructura Base API Core"
status: in-progress
priority: critical
created: "2026-04-10"
started: "2026-04-10"
completed: null
tags: [auth, api_core, migration]
---

# TASK-001: Migración de Módulo Auth y Estructura Base API Core

## Descripcion
Esta tarea consiste en establecer los cimientos de `api_core` migrando la lógica de autenticación desde la plantilla `template_backend_python`. Se debe implementar bajo principios de Clean Architecture y DDD.

## Objetivos
- [ ] Estructurar contextos en `api_core` (person, account, security).
- [ ] Migrar lógica de JWT.
- [ ] Implementar validación global (ADR-002).
- [ ] Configurar conectores para Multi-DB (ADR-003).

## Enlaces Rapidos
- [Plan de Ejecución](planning/README.md)
- [Registro de Progreso](progress/)
- [Artefactos](artifacts/)
