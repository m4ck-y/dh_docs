# Estado del Proyecto (LLM Context)

**Última actualización**: 2026-05-02

## Hitos de Arquitectura Recientes
- **Estandarización de Auth**: Implementado `dh_auth` con Stateless JWT (HttpOnly cookies) y silent refresh.
- **Unified Registry**: Implementación de `shared_registry` en `dh_shared` para resolver relaciones cross-schema (Auth, People, Org, IAM) en una base de datos única.
- **Perfil de Usuario Enriquecido**: El endpoint `/me` ahora agrega datos de múltiples esquemas (Persona + Empleado + Empresa + Membresías + Roles/Permisos).
- **Observabilidad**: Eliminación total de `print()` a favor de `ServiceLogger` con forward asíncrono a VitalTrace.
- **Seguridad**: Estandarización de Argon2 para todo el ecosistema (centralizado en `dh_shared.utils.security`).
- **IAM Service**: Microservicio `dh_iam` implementado con RBAC completo (Tenants, Resources, Operations, Permissions, Roles, Memberships, Context API). 32 endpoints con paginación, UUIDs en API pública, auto-generación de permission keys.
- **UUID-only API**: ADR 024 establece que todos los endpoints públicos usan UUIDs, prohibiendo IDs autoincrementales en la interfaz externa.
- **Static Test UI**: ADR 025 establece estándar para UI de prueba retro terminal en cada microservicio (implementado en `dh_auth` y `dh_iam`).

## Estado de los Servicios

| Servicio | Estado | Notas |
| :--- | :--- | :--- |
| `api_middleware` | Activo | Gateway único. Pendiente inyectar validación RBAC. |
| `dh_auth` | **Activo** | Stateless Auth, Login, Logout, Me. Sincroniza esquemas core. UI retro terminal en `/`. |
| `dh_onboarding_back` | **Activo** | Flujo completo waitlist -> person. Password hashing Argon2 OK. |
| `dh_core` | **Activo** | Personas completo: Person, Email, Phone, Address, PersonalIdentifier, EmergencyContact. UI con tabs. Cumple ADR 009, 006, 022, 024, 025. |
| `app_logger_tracer` (VitalTrace) | Activo | Ingesta de logs asíncrona. |
| `app_message_sender` (PulseCore) | Activo | OTP, Invites y Welcome messages. |
| `dh_mfa` | Completo | OTP challenge integrado. |
| `dh_iam` | **Activo** | RBAC completo: 32 endpoints, CRUD Tenants/Resources/Operations/Permissions/Roles/Memberships, Context API. Seeders con datos por defecto. UI admin retro terminal en `/`. |
| `dh_organizations` | En progreso (Modelos OK) | Modelos de Company/Employee integrados. |

## Objetivos Inmediatos

1. Finalizar `dh_organizations` (TASK-010) para estructurar la jerarquía corporativa.
2. Integrar validación de RBAC en el `api_middleware` usando los claims del JWT.
3. Implementar `dh_documents` para manejo de archivos.
4. Conectar `dh_auth` + `dh_iam` real via HTTP (endpoint `/v1/iam/context/{uuid}`).

## Tasks

| Task | Título | Status |
| :--- | :--- | :--- |
| TASK-003 | Microservicio de Onboarding (dh_onboarding_back) | **Completada** |
| TASK-004 | Microservicio de Auth (dh_auth) | **Completada** |
| TASK-006 | Microservicio MFA — OTP Challenge (dh_mfa) | **Completada** |
| TASK-009 | Microservicio de IAM (dh_iam) | **Completada** |
| TASK-010 | Microservicio de Organizaciones (dh_organizations) | **En progreso** |
| TASK-011 | Centralización de `Person` en `dh_core` | **Completada** |

---
*Este documento es la fuente de verdad para el contexto de la IA.*
