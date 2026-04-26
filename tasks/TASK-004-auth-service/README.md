---
type: task
id: TASK-004
title: "Extraccion de Auth a Microservicio Independiente (app_auth)"
status: backlog
priority: critical
created: "2026-04-25"
started: null
completed: null
tags: [auth, security, microservices, decoupling]
---

# TASK-004: Extraccion de Auth a Microservicio Independiente (app_auth)

## Descripcion
Separar la logica de autenticacion, gestion de tokens (JWT) y multi-factor (MFA) de `api_core` hacia un microservicio dedicado. Este servicio sera el unico responsable de los schemas `auth` y `mfa`.

## Objetivos
- [ ] Inicializar el repositorio `app_auth`.
- [ ] Migrar los modelos de SQLAlchemy de `auth` y `mfa` desde `api_core`.
- [ ] Implementar endpoints de Login, Refresh, Logout y MFA Verification.
- [ ] Configurar el sistema de llaves (Public/Private) para la firma y validacion de JWTs entre microservicios.
- [ ] Actualizar `api_middleware` para que el routing de `/auth` apunte al nuevo servicio.

## Enlaces Rapidos
- [Plan de Ejecucion](planning/README.md)
- [Registro de Progreso](progress/README.md)
- [Artefactos](artifacts/)
