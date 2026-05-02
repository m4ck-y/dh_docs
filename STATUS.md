# Estado del Proyecto (LLM Context)

**Última actualización**: 2026-05-01

## Hitos de Arquitectura Recientes
- **Estandarización de Auth**: Implementado `dh_auth` con Stateless JWT (HttpOnly cookies) y silent refresh.
- **Unified Registry**: Implementación de `shared_registry` en `dh_shared` para resolver relaciones cross-schema (Auth, People, Org, IAM) en una base de datos única.
- **Perfil de Usuario Enriquecido**: El endpoint `/me` ahora agrega datos de múltiples esquemas (Persona + Empleado + Empresa + Membresías + Roles/Permisos).
- **Observabilidad**: Eliminación total de `print()` a favor de `ServiceLogger` con forward asíncrono a VitalTrace.
- **Seguridad**: Estandarización de Argon2 para todo el ecosistema (centralizado en `dh_shared.utils.security`).

## Resumen Ejecutivo

La base de identidad y seguridad está consolidada. Los microservicios `dh_auth` y `dh_onboarding_back` operan bajo el mismo estándar de persistencia y observabilidad. La librería `dh_shared` actúa como el contrato estricto de modelos y utilidades compartidas.

## Estado de los Servicios

| Servicio | Estado | Notas |
| :--- | :--- | :--- |
| `api_middleware` | Activo | Gateway único. Pendiente inyectar validación RBAC. |
| `dh_auth` | **Activo** | Stateless Auth, Login, Logout, Me. Sincroniza esquemas core. |
| `dh_onboarding_back` | **Activo** | Flujo completo waitlist -> person. Password hashing Argon2 OK. |
| `app_logger_tracer` (VitalTrace) | Activo | Ingesta de logs asíncrona. |
| `app_message_sender` (PulseCore) | Activo | OTP, Invites y Welcome messages. |
| `dh_mfa` | Completo | OTP challenge integrado. |
| `dh_iam` | En progreso (Modelos OK) | Modelos integrados en shared_registry. |
| `dh_organizations` | En progreso (Modelos OK) | Modelos de Company/Employee integrados. |

## Objetivos Inmediatos

1. Finalizar `dh_iam` (TASK-009) para gestionar asignación de roles y creación de tenants.
2. Finalizar `dh_organizations` (TASK-010) para estructurar la jerarquía corporativa.
3. Integrar validación de RBAC en el `api_middleware` usando los claims del JWT.
4. Implementar `dh_documents` para manejo de archivos.

## Tasks

| Task | Título | Status |
| :--- | :--- | :--- |
| TASK-003 | Microservicio de Onboarding (dh_onboarding_back) | **Completada** |
| TASK-004 | Microservicio de Auth (dh_auth) | **Completada** |
| TASK-006 | Microservicio MFA — OTP Challenge (dh_mfa) | **Completada** |
| TASK-009 | Microservicio de IAM (dh_iam) | **En progreso** |
| TASK-010 | Microservicio de Organizaciones (dh_organizations) | **En progreso** |
| TASK-011 | Centralización de `Person` en `dh_core` | Refactorizado vía dh_shared |

---
*Este documento es la fuente de verdad para el contexto de la IA.*
