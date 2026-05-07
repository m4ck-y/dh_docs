# Estado del Proyecto (LLM Context)

**Última actualización**: 2026-05-05

## Hitos de Arquitectura Recientes
- **UUID v7**: Reemplazo de `uuid4` por `uuid7` (time-ordered) en `BaseModelMixin` para indices B-tree eficientes. Libreria `uuid6`.
- **dh_storage**: Microservicio implementado (puerto 8060). Storage layer para fotos (people.photo) y documentos (storage.*). DiskStorage con abstraccion swappable. 9 endpoints: documents POST/GET/DELETE, photo POST/GET/DELETE, files GET download, config types/subtypes. UI retro con 4 tabs.
- **dh_admin** (antes dh_backoffice): Admin panel con endpoint drop/recreate schemas. UI retro en `/`.
- **init_schemas**: ADR 030 — reemplaza `sync_schemas` en todos los servicios. Crea 8 schemas, luego `shared_metadata.create_all`. SQLAlchemy resuelve FKs circulares. Sin orden de arranque.
- **Sub-objetos en DTOs**: ADR 029 — `CreatePersonDTO` con `email: {address, type}`, `phone: {code, number, type}`, `birth: {date, key_country, key_state}`. Naming sin prefijos redundantes.
- **Renombres**: Schema `expedient` → `storage`. `dh_backoffice` → `dh_admin`.

## Estado de los Servicios

| Servicio | Estado | Notas |
| :--- | :--- | :--- |
| `api_middleware` | **Activo** | 8 sub-apps montadas con schemas duplicados. 3 servicios listados como PENDING en docstring. |
| `dh_auth` | **Activo** | Stateless Auth, Login, Logout, Me, Refresh. UI retro terminal en `/`. |
| `dh_iam` | **Activo** | RBAC completo: 32 endpoints. UI retro terminal en `/`. Scrollbars cyberpunk. |
| `dh_core` | **Activo** | CRUD completo Person + sub-entidades (27 endpoints). Soft-delete, UUID-only. UI retro terminal con 6 tabs. |
| `dh_mfa` | **Activo** | OTP challenge (create, verify, resend). Naming `uuid_challenge` estandarizado. |
| `dh_onboarding_back` | **Activo** | Flujo onboarding step-by-step. UI retro con 3 tabs (Waitlist, Onboarding, Legacy) y auto-avance. |
| `app_logger_tracer` (VitalTrace) | TESTING | Ingesta de logs. |
| `app_message_sender` (PulseCore) | TESTING | OTP, Invites, Welcome messages. |
| `dh_organizations` | PENDING | Modelos de Company/Employee en dh_shared. Sin servicio. |
| `dh_catalogs` | PENDING | No iniciado. |
| `dh_storage` | **Activo** | 9 endpoints: documents, photos, files, config. PUERTO 8060. |
| `dh_admin` | **Activo** | Admin DB — drop/recreate schemas. UI retro en `/`. Puerto 8050. |

## Objetivos Inmediatos

1. Implementar `dh_organizations` para estructurar la jerarquia corporativa.
2. Integrar validacion de RBAC en el `api_middleware` usando los claims del JWT (ADR 015).
3. Implementar `dh_catalogs`.
4. Conectar `dh_auth` + `dh_iam` real via HTTP (endpoint `/v1/iam/context/{uuid_person}`).

## Tasks

| Task | Titulo | Status |
| :--- | :--- | :--- |
| TASK-003 | Microservicio de Onboarding (dh_onboarding_back) | **Completada** |
| TASK-004 | Microservicio de Auth (dh_auth) | **Completada** |
| TASK-006 | Microservicio MFA — OTP Challenge (dh_mfa) | **Completada** |
| TASK-007 | Storage Service (dh_storage) | **Completada** |
| TASK-009 | Microservicio de IAM (dh_iam) | **Completada** |
| TASK-010 | Microservicio de Organizaciones (dh_organizations) | **Pendiente** |
| TASK-011 | Centralizacion de `Person` en `dh_core` | **Completada** |

---

## ADRs Recientes (ultima sesion)

| ADR | Titulo |
| :--- | :--- |
| ADR 010 (actualizado) | Estrategia de IDs — convencion estricta `uuid_` / `id_` sin sufijos |
| ADR 024 (actualizado) | UUIDs en API publica — alineado con ADR 010 |
| ADR 026 | Resolucion local del `id` interno post-respuesta de microservicio |
| ADR 027 | API Middleware — enlace a Test UI de cada microservicio |
| ADR 029 | Sub-objetos en DTOs — agrupacion semantica sin prefijos redundantes |
| ADR 030 | init_schemas — inicializacion centralizada de schemas (reemplaza sync_schemas) |
| ADR 031 | Configuracion baseline para microservicios — ROOT_PATH, CORS, checklist |
| ADR 032 | Politica de emojis como indicadores de estado — 🟢🟡🔴 solo tres colores |
| ADR 033 | Docstrings Swagger — templates y placeholders para `description=__doc__` |

---

*Este documento es la fuente de verdad para el contexto de la IA.*