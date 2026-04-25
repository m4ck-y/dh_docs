# auth

Schema de PostgreSQL para autenticacion y sesiones.

Gestiona credenciales de acceso, dispositivos de confianza, sesiones activas, intentos de login y recuperacion de contrasena.

## Entidades

| Entidad | Descripcion |
|---|---|
| `user` | Metodo de autenticacion de la persona (password, OAuth, magic link) |
| `device` | Dispositivos de confianza donde el usuario inicia sesion |
| `session` | Sesiones activas del usuario con estado y tokens |
| `login_attempt` | Intentos de login para seguridad y rate limiting |
| `password_reset` | Flujo de recuperacion de contrasena |

## Enums

| Enum | Valores |
|---|---|
| `ECredentialType` | `PASSWORD`, `OAUTH`, `MAGIC_LINK` |
| `ESessionStatus` | `ACTIVE`, `REVOKED`, `EXPIRED` |
| `ELoginAttemptStatus` | `SUCCESS`, `FAILED`, `BLOCKED` |

## Dependencias externas

| Schema | Tabla | Uso |
|--------|-------|-----|
| `people` | `person` | Todas las entidades referencian `person` via `id_person FK` |

## Archivos

| Archivo | Descripcion |
|---|---|
| [ERD.mmd](./ERD.mmd) | Diagrama ERD del schema en Mermaid |
