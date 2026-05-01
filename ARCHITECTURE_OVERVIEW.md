# Arquitectura de Digital Hospital: Mapa de Propiedad y Servicios

Este documento define la responsabilidad única de cada microservicio y la propiedad de los datos en el ecosistema.

## 🗺️ Matriz de Propiedad de Datos (Ownership)

| Microservicio | Esquema / Tablas de las que es DUEÑO | Responsabilidad Principal |
| :--- | :--- | :--- |
| **`dh_auth`** | `auth.AuthUser`, `auth.Session` | Autenticación, contraseñas y Google OAuth. |
| **`dh_iam`** | `iam.Tenant`, `iam.Membership`, `iam.Role`, `iam.Permission` | Autorización multi-tenant y RBAC. |
| **`dh_core`** | `people`, `relationships` | Maestro de personas y vínculos sociales. |
| **`dh_catalogs`** | `catalog` | Catálogos globales del sistema. |
| **`dh_clinical`** | `health_profile` | Gestión clínica inicial, alergias, vacunas y antecedentes. |
| **`dh_health_monitoring`** | `vitals` | Registro de signos vitales y monitoreo en tiempo real. |
| **`dh_organizations`** | `org.Company`, `org.Employee`, `org.Location`, `org.Industry` | Estructura administrativa y laboral. |
| **`dh_mfa`** | `mfa.OTP_Log` | Desafíos de segundo factor (SMS/Email/TOTP). |
| **`dh_expedient`** | `expedient` | Gestión de archivos físicos, expedientes y validación documental. |

## 🛠️ Servicios de Orquestación (Sin Propiedad de Tablas Core)

Estos servicios no "son dueños" de tablas maestras, sino que coordinan procesos llamando a otros servicios:

- **`dh_onboarding_back`**: Orquesta el flujo de auto-registro. Consume `dh_core`, `dh_auth` y `dh_iam`.
- **`dh_seeder`**: Herramienta de desarrollo para poblar el sistema. Consume todos los servicios vía API. No tiene base de datos propia.
- **`api_middleware`**: Puerta de enlace (Gateway). Valida seguridad stateless y redirige tráfico.

## 📊 Estado y Prioridades de Implementación

| ID Task | Microservicio | Estado | Prioridad |
| :--- | :--- | :--- | :--- |
| TASK-004 | `dh_auth` | Backlog | **CRÍTICA** |
| TASK-009 | `dh_iam` | Backlog | **CRÍTICA** |
| TASK-011 | `api_core` (Refactor) | Backlog | **Alta** |
| TASK-010 | `dh_organizations` | Backlog | **Alta** |
| TASK-003 | `dh_onboarding_back` | En Progreso | Media |
| TASK-007 | `dh_documents` | Backlog | Media |
| TASK-012 | `dh_seeder` | Backlog | Baja |

## 🔗 Referencias Arquitectónicas
- [ADR 015: Autorización Stateless](./decisions/015-estrategia-autorizacion-stateless.md)
- [ADR 016: Tipos de Membresía y Contexto de Usuario](./decisions/016-tipos-de-membresia-y-contexto-de-usuario.md)
