---
type: task
id: TASK-009
title: "Microservicio de Identity & Access Management (dh_iam)"
status: backlog
priority: high
created: "2026-04-26"
started: null
completed: null
tags: ["iam", "rbac", "tenants", "permissions"]
---

# TASK-009: Microservicio de Identity & Access Management (dh_iam)

## 📝 Descripción
Desarrollar el "cerebro" de autorización del sistema. `dh_iam` será el responsable de gestionar quién puede hacer qué (RBAC) y en qué contexto (Tenants/Memberships). 

Este servicio debe servir a dos canales de entrada:
1. **Canal Onboarding**: Asignación automática de roles básicos (Paciente) tras validación OTP/Docs.
2. **Canal Administrativo**: Registro directo de empleados y médicos por parte de un administrador (Backoffice).

## 🔑 Concepto: Multi-Membresía y Multi-Rol
- **Memberships**: Gestiona el vínculo entre la identidad (`person_id`) y la organización (`tenant_id`).
- **Agregación de Roles**: Capacidad de sumar permisos de múltiples roles (ej: Médico + Jefe de Área) en una sola membresía.

## 🎯 Objetivos
- [ ] Inicializar el repositorio `dh_iam` con Screaming Architecture.
- [ ] **Gestión de Tenants**: CRUD de organizaciones (vinculado a `dh_organizations`).
- [ ] **Gestión de Roles y Permisos**: Definición de catálogo global de permisos (recurso:operación).
- [ ] **Gestión de Memberships**: APIs para crear, suspender y asignar roles a membresías.
- [ ] **API de Contexto para Auth**: Endpoint que devuelva el "Active Context" (permisos agregados) para que `dh_auth` emita el JWT.
- [ ] **Lógica de Doble Carril**: 
    - APIs para `dh_onboarding_back` (roles básicos).
    - APIs para `dh_organizations` (roles profesionales manuales).

## 📜 Log de Cambios
- **2026-04-26**: Renombramiento global para consistencia. Se vincula con `dh_core` (antes api_core) para la obtención de `person_id`.
- **2026-04-26**: Definición de esquema `relationships` (antes care) como apoyo a la lógica de membresías familiares.

## 🔗 Enlaces Rápidos
- [Plan de Ejecución](planning/README.md)
- [Registro de Progreso](progress/)
- [Artefactos](artifacts/)
