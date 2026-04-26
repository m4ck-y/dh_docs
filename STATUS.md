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
| `dh_onboarding_back` | En desarrollo | OTP conectado. Pendiente: password hashing. |
| `dh_mfa` | Completo | OTP challenge. |
| `dh_documents` | Backlog | Storage evolutivo (disk/GCS). Validación configurable. |
| `app_questionnaire` | Estable | FormFlow operativo. |

## Bloqueos Actuales

- Endpoints OTP en `dh_onboarding_back` (`/otp/send`, `/otp/verify`) ya conectados con `dh_mfa` via httpx.
- Password hashing pendiente de `dh_auth` (TASK-004) — actualmente almacena texto plano.

## Objetivos Inmediatos

1. ~~Conectar `dh_onboarding_back` con `dh_mfa` para el paso OTP del onboarding~~ (completado).
2. Implementar `dh_auth` (TASK-004) — login, OAuth Google, JWT, password hashing.
3. Implementar endpoints de admin review en `api_core` (ver TASK-005 backoffice).
4. Implementar `dh_documents` (TASK-007) — storage evolutivo, validación configurable.

## Tasks

| Task | Título | Status |
| :--- | :--- | :--- |
| TASK-001 | Auditoría de DB | Completada |
| TASK-002 | Módulo Waitlist en dh_onboarding_back | **Completada** |
| TASK-003 | Microservicio de Onboarding (dh_onboarding_back) | **En progreso (OTP conectado)** |
| TASK-004 | Microservicio de Auth (dh_auth) | Backlog |
| TASK-005 | Backoffice Administrativo (dh_backoffice) | Backlog |
| TASK-006 | Microservicio MFA — OTP Challenge (dh_mfa) | **Completada** |
| TASK-007 | Microservicio de Gestión de Documentos (dh_documents) | Backlog |

---
*Este documento es la fuente de verdad para el contexto de la IA.*
