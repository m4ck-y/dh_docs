# Estado del Proyecto (LLM Context)

**Última actualización**: 2026-04-26

## Resumen Ejecutivo

El flujo de auto-registro (waitlist → onboarding → person) está implementado y funcional en `dh_onboarding_back`. El microservicio MFA (`dh_mfa`) tiene su primera fase completa con OTP challenge. Los servicios de auth y backoffice están pendientes.

## Estado de los Servicios

| Servicio | Estado | Notas |
| :--- | :--- | :--- |
| `api_middleware` | Activo | Gateway único. |
| `api_core` | En Refactor | Auditoría de DB completada. Schemas actualizados. |
| `app_logger_tracer` (VitalTrace) | Activo en Cloud Run | Migrado a lifespan. Filtrado MongoDB corregido. |
| `app_message_sender` (PulseCore) | Activo en Cloud Run | Waitlist confirmation, invite, OTP, welcome. |
| `dh_onboarding_back` | En desarrollo | OTP conectado. Validación de duplicados implementada. Pendiente: password hashing. |
| `dh_mfa` | Completo | OTP challenge. |
| `dh_documents` | Backlog | Storage evolutivo (disk/GCS). Validación configurable. |
| `app_questionnaire` | Estable | FormFlow operativo. |

## Bloqueos Actuales

- Ninguno crítico. Los endpoints OTP ya están conectados y el hashing de contraseñas ha sido implementado.
- Pendiente de iniciar `dh_auth` (TASK-004) para centralizar login y emisión de JWT.

## Objetivos Inmediatos

1. ~~Conectar `dh_onboarding_back` con `dh_mfa` para el paso OTP del onboarding~~ (completado).
2. ~~Implementar hashing de contraseñas en onboarding (Bcrypt)~~ (completado).
3. Implementar `dh_auth` (TASK-004) — Login y emisor de JWT.
4. Implementar `dh_iam` (TASK-009) — Gestión de Roles, Permisos y Tenants.
5. Implementar `dh_organizations` (TASK-010) — Estructura corporativa y empleados.
6. Implementar validación de RBAC en `api_middleware` basado en claims de JWT.

## Tasks

| Task | Título | Status |
| :--- | :--- | :--- |
| TASK-001 | Auditoría de DB | Completada |
| TASK-002 | Módulo Waitlist en dh_onboarding_back | **Completada** |
| TASK-003 | Microservicio de Onboarding (dh_onboarding_back) | **En progreso (OTP y Hashing OK)** |
| TASK-004 | Microservicio de Auth (dh_auth) | **PRIORIDAD CRÍTICA (Next)** |
| TASK-009 | Microservicio de IAM (dh_iam) | **PRIORIDAD CRÍTICA (Next)** |
| TASK-010 | Microservicio de Organizaciones (dh_organizations) | **Prioridad Alta** |
| TASK-005 | Backoffice Administrativo (dh_backoffice) | Backlog |
| TASK-006 | Microservicio MFA — OTP Challenge (dh_mfa) | **Completada** |
| TASK-007 | Microservicio de Expediente y Docs (dh_expedient) | Prioridad Media |
| TASK-011 | Centralización de `Person` en `dh_core` | **Prioridad Alta (Refactor)** |
| TASK-012 | Orquestador de Seeders Global (System Seeder) | Backlog |

## Notas Técnicas

- **Multi-Membresía**: Se refiere a la capacidad de una `person` de estar vinculada a múltiples `tenants`. Al autenticarse, el usuario debe seleccionar un "Contexto Activo", lo que resulta en un JWT con el `tenant_id` y los `roles` específicos de esa membresía.
- **Stateless Auth**: El middleware no consulta la base de datos; confía plenamente en los permisos (`recurso:operacion`) inyectados por `dh_auth` en el JWT.
- **Migración User**: La entidad `user` se movió del schema `people` al schema `auth` para eliminar duplicación y clarificar responsabilidades (ADR 018).

---
*Este documento es la fuente de verdad para el contexto de la IA.*
