---
type: task
id: TASK-010
title: "Microservicio de Organizaciones y Empleados (dh_organizations)"
status: backlog
priority: high
created: "2026-04-26"
started: null
completed: null
tags: ["organizations", "employees", "companies", "hr"]
---

# TASK-010: Microservicio de Organizaciones y Empleados (dh_organizations)

## 📝 Descripción
Desarrollar el microservicio encargado de la estructura corporativa y el capital humano. A diferencia del onboarding, este servicio gestiona el **Registro Administrativo** de personal.

## 🔑 Responsabilidades
1. **Estructura Corporativa**: Gestión de Industrias, Compañías, Sedes (Locations) y Servicios ofrecidos.
2. **Gestión de Empleados**: Alta directa de personal (médicos, administrativos) sin necesidad de pasar por el flujo de onboarding de pacientes.
3. **Clasificación Profesional**: Uso de `personal_type` para categorizar al capital humano.

## 🎯 Objetivos
- [ ] Inicializar el repositorio `dh_organizations` con Screaming Architecture.
- [ ] **CRUD de Organizaciones**: Implementar lógica para Industrias, Compañías y Locaciones (ADR 003).
- [ ] **Alta Administrativa de Empleados**: Endpoint para que un administrador cree una ficha de empleado vinculada a una `person` y una `company`.
- [ ] **Sincronización con IAM**: Al crear un empleado, notificar a `dh_iam` para generar la `membership` correspondiente.
- [ ] **Catálogo de Servicios**: Gestión de los servicios médicos que ofrece cada compañía.

## 🔗 Enlaces Rápidos
- [Plan de Ejecución](planning/README.md)
- [Registro de Progreso](progress/)
- [Artefactos](artifacts/)
