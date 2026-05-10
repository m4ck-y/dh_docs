# Matriz de Acceso: Servicios y Schemas de Datos

Este documento define la propiedad y los permisos de acceso de cada microservicio sobre los diferentes schemas y bases de datos del ecosistema.

## Principios de Acceso
1. **Propiedad (Owner)**: Solo un microservicio es dueño (escritura/migraciones) de un schema.
2. **Ningún endpoint expone `id`**: Toda respuesta HTTP devuelve `uuid`. El `id` integer es estrictamente interno a la DB. Ver ADR 017.
3. **FK cross-service con `id` real**: Los FKs entre schemas de distintos servicios usan `id` Integer con constraint real en DB — misma instancia PostgreSQL.
4. **Resolución `uuid → id` via lectura directa**: Cuando un servicio necesita el `id` de una entidad ajena para una FK, lo resuelve con un `SELECT` de solo lectura (modelo `*Ref`) — nunca vía HTTP. Ver ADR 017.

## Matriz de Persistencia Relacional (PostgreSQL)

| Servicio | Schema | Acceso | Notas |
|:---------|:-------|:------:|:------|
| `dh_core` | `people` | **Owner** | Personas, vínculos sociales. |
| `dh_auth` | `auth` | **Owner** | Credenciales y sesiones. Referencias a `people` via `person_uuid` (UUID lógico). |
| `dh_iam` | `iam` | **Owner** | Roles, membresías, permisos, tenants. |
| `dh_mfa` | `mfa` | **Owner** | Desafíos OTP y factores MFA. |
| `dh_storage` | `storage` | **Owner** | Documentos, fotos e identificadores. Storage layer unico. |
| `dh_clinical` | `health_profile` | **Owner** | Perfiles clínicos, alergias, antecedentes. |
| `dh_organizations` | `org` | **Owner** | Empresas, empleados, sedes, servicios. |
| `dh_catalogs` | `catalog` | **Owner** | Catálogos globales del sistema. |

## Regla de Referencias Cross-Service

Cuando un schema necesita vincular una entidad de otro servicio:
- Usar `person_uuid UUID` (sin FK constraint) — no hay integridad referencial entre servicios.
- No usar `id_person INTEGER FK → people.person.id` — esa FK implica acceso directo al schema ajeno.

## Matriz de Persistencia No Relacional (MongoDB)

| Servicio | Base de Datos / Colección | Acceso | Notas |
|:---------|:--------------------------|:------:|:------|
| `dh_onboarding` | `dh_onboarding / waitlist` | **Owner** | Leads y waitlist. |
| `dh_mfa` | `dh_mfa / otp_challenge` | **Owner** | Challenges OTP con TTL. |
| `dh_logger` | `telemetry_events` | **Owner** | Logs y trazabilidad. |

## Interdependencias por Flujo de Negocio

| Origen | Destino | Tipo | Razón |
|:-------|:--------|:----:|:------|
| `dh_onboarding` | `dh_core` | API | Creación y actualización de `person`. |
| `dh_onboarding` | `dh_mfa` | API | Desafíos OTP durante onboarding. |
| `dh_onboarding` | `dh_auth` | API | Registro de `AuthUser` y set password (TASK-004 pendiente). |
| `dh_auth` | `dh_iam` | API | Consulta permisos y membresías para emitir JWT. |
| `api_middleware` | — | JWT | Valida JWT stateless, sin acceso a DB. |
| `Cualquier servicio` | `dh_logger` | API | Telemetría y logs (VitalTrace). |
| `Cualquier servicio` | `dh_notify` | API | Envío de emails/SMS (PulseCore). |

---
*Actualizar cuando se cree un nuevo microservicio o se añada un schema.*
