# Estado del Proyecto (LLM Context)

**Última actualización**: 2026-05-08

## Hitos de Arquitectura Recientes
- **Renombres**: `dh_logger_tracer` → `dh_logger`, `dh_message_sender` → `dh_notify`. ROOT_PATH unificados: `/api/logger`, `/api/notify`.
- **Deploy automático**: Plan systemd + GitHub Actions para todos los microservicios. `.service` files en `docs/`, workflows en `.github/workflows/deploy.yml`.
- **dh_admin montado en gateway**: Integrado como sub-app en `api_middleware` bajo `/admin`. 2 rutas proxy (`POST /v1/db/recreate`, `POST /v1/db/seed-all`).
- **Roles de puertos**: api_middleware en 8080 (público), backends 8081-8092 (red interna). dh_admin → 8088, dh_storage → 8087.
- **UUID v7**: Reemplazo de `uuid4` por `uuid7` (time-ordered) en `BaseModelMixin` para indices B-tree eficientes. Libreria `uuid6`.
- **Sub-objetos en DTOs**: ADR 029 — `CreatePersonDTO` con `email: {address, type}`, `phone: {code, number, type}`, `birth: {date, key_country, key_state}`. Naming sin prefijos redundantes.
- **init_schemas**: ADR 030 — reemplaza `sync_schemas` en todos los servicios. Crea 8 schemas, luego `shared_metadata.create_all`. SQLAlchemy resuelve FKs circulares.

## Estado de los Servicios

| Servicio | Estado | Notas |
| :--- | :--- | :--- |
| `api_middleware` | **Activo** | 10 sub-apps montadas (auth, iam, core, mfa, onboarding, health_monitoring, storage, admin, notify, logger). 3 PENDING. Puerto 8080 público. |
| `dh_auth` | **Activo** | Stateless Auth, Login, Logout, Me, Refresh. UI retro terminal en `/`. Puerto 8081. |
| `dh_iam` | **Activo** | RBAC completo: 32 endpoints. UI retro terminal en `/`. Scrollbars cyberpunk. Puerto 8082. |
| `dh_core` | **Activo** | CRUD completo Person + sub-entidades (27 endpoints). Soft-delete, UUID-only. UI retro terminal con 6 tabs. Puerto 8083. |
| `dh_mfa` | **Activo** | OTP challenge (create, verify, resend). Naming `uuid_challenge` estandarizado. Puerto 8084. |
| `dh_onboarding` | **Activo** | Flujo onboarding step-by-step. UI retro con 3 tabs (Waitlist, Onboarding, Legacy) y auto-avance. Puerto 8085. |
| `dh_health_monitoring` | **Activo** | Monitoreo clínico: mediciones, tipos, reportes. Puerto 8086. |
| `dh_storage` | **Activo** | 9 endpoints: documents, photos, files, config. Puerto 8087. Montado en gateway. |
| `dh_admin` | **Activo** | Admin DB — drop/recreate schemas, seed. UI retro en `/`. Puerto 8088. Montado en gateway. |
| `dh_logger` (VitalTrace) | TESTING | Ingesta de logs, trazas, métricas. Puerto 8092. ROOT_PATH `/api/logger`. |
| `dh_notify` (PulseCore) | TESTING | OTP, Invites, Welcome messages. Puerto 8091. ROOT_PATH `/api/notify`. |

## Objetivos Inmediatos

1. Implementar `dh_organizations` para estructurar la jerarquia corporativa.
2. Integrar validacion de RBAC en el `api_middleware` usando los claims del JWT (ADR 015).
3. Implementar `dh_catalogs`.
4. Conectar `dh_auth` + `dh_iam` real via HTTP (endpoint `/v1/iam/context/{uuid_person}`).

## Tasks

| Task | Titulo | Status |
| :--- | :--- | :--- |
| TASK-003 | Microservicio de Onboarding (dh_onboarding) | **Completada** |
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
| ADR 035 | API Path Format — prohibido trailing slash en endpoints |
| ADR 035 | API Path Format — prohibido trailing slash en endpoints |

---

*Este documento es la fuente de verdad para el contexto de la IA.*