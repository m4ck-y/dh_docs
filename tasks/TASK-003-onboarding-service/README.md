---
type: task
id: TASK-003
title: "Implementacion de Microservicio de Onboarding"
status: backlog
priority: high
created: "2026-04-25"
started: null
completed: null
tags: [onboarding, backend, orchestration]
---

# TASK-003: Implementacion de Microservicio de Onboarding

## Descripcion
Desarrollo del servicio `dh_onboarding_back` encargado de orquestar el flujo de registro de nuevos usuarios (Applicants). Este servicio gestiona el estado del proceso de onboarding y coordina las llamadas a los servicios de identidad y seguridad.

## Objetivos
- [ ] Definir la estructura base del proyecto (FastAPI + Hexagonal Architecture).
- [ ] Implementar la maquina de estados para el proceso de 4 pasos (Personal Info, OTP, Password, Documents).
- [ ] Implementar la integracion con `app_waitlist` para validar tokens de invitacion.
- [ ] Implementar la integracion con `api_core` para crear la entidad `Person`.
- [ ] Implementar la integracion con `app_auth` para crear las credenciales del usuario.

## Enlaces Rapidos
- [Plan de Ejecucion](planning/README.md)
- [Registro de Progreso](progress/README.md)
- [Artefactos](artifacts/)
