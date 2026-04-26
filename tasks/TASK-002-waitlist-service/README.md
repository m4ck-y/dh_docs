---
type: task
id: TASK-002
title: "Implementación de Módulo Waitlist en dh_onboarding_back (MongoDB/Beanie)"
status: backlog
priority: high
created: "2026-04-25"
started: null
completed: null
tags: [onboarding, mongodb, beanie, waitlist]
---

# TASK-002: Implementación de Módulo Waitlist en dh_onboarding_back (MongoDB/Beanie)

## Descripcion
Desarrollo del módulo de Waitlist dentro del microservicio `dh_onboarding_back` utilizando MongoDB con Beanie ODM. Este servicio es el punto de entrada inicial para el flujo de onboarding.

## Objetivos
- [ ] Configurar conexión MongoDB con Beanie en dh_onboarding_back.
- [ ] Definir el esquema de la colección `waitlist` en MongoDB.
- [ ] Implementar el CRUD básico de leads (Create, Read, List).
- [ ] Implementar la lógica de generación y almacenamiento de tokens de invitación.
- [ ] Exponer endpoints para gestionar waitlist.
- [ ] Exponer endpoint para convertir lead en applicant (iniciar onboarding).

## Enlaces Rapidos
- [Plan de Ejecución](planning/README.md)
- [Registro de Progreso](progress/README.md)
- [Artefactos](artifacts/)
