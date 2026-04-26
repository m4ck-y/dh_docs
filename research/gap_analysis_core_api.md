# Analisis de Inconsistencias: api_core y Schemas de Datos

**Fecha**: 2026-04-25
**Estado**: Pendiente de Decision

## 1. Problema de Alineacion
Actualmente existe un desacoplamiento entre los nombres de los schemas de PostgreSQL y los Bounded Contexts definidos en el codigo fuente de `api_core`.

### Matriz de Inconsistencias actual

| Contexto Backend | Schema PostgreSQL | Problema |
|:-----------------|:------------------|:---------|
| `person` | `people` | Inconsistencia menor de nombre (Person vs People). |
| `security` | `auth` + `mfa` | Sobrecarga. Un contexto maneja dos dominios distintos. |
| `account` | `iam` (parcial) | Fragmentacion. |
| `company` | `iam` (parcial) | Fragmentacion. |
| `employee` | `iam` (parcial) | Fragmentacion. |

## 2. Propuesta de Reorganizacion (Alineacion 1:1)

Para cumplir con la **Screaming Architecture**, el backend debe reflejar la estructura de datos. Se propone consolidar los contextos de la siguiente manera:

### Contexto: `people` (antes `person`)
- **Dominio**: Datos demograficos, direcciones, contactos.
- **Schema**: `people`.
- **Entidades**: `person`, `email`, `phone`, `address`, `birth`, `legal_info`.

### Contexto: `auth` (antes parte de `security`)
- **Dominio**: Autenticacion, JWT, Sesiones.
- **Schema**: `auth`.
- **Entidades**: `user`, `session`, `device`, `login_attempt`.

### Contexto: `mfa` (antes parte de `security`)
- **Dominio**: Multi-factor authentication.
- **Schema**: `mfa`.
- **Entidades**: `auth_factor`, `otp_challenge`, `recovery_code`.

### Contexto: `iam` (reemplaza `account`, `company`, `employee`)
- **Dominio**: Identity & Access Management (Roles, Permisos, Membresias).
- **Schema**: `iam`.
- **Entidades**: `membership`, `role`, `permission`.
- *Nota*: `company` y `employee` pasan a ser atributos o tipos de membresia dentro de este contexto.

## 3. Hoja de Ruta Sugerida

1.  **Refactor de Nombres**: Renombrar carpetas en `app/contexts/` para que coincidan con los schemas.
2.  **Consolidacion de IAM**: Mover la logica de `account`, `company` y `employee` al nuevo contexto `iam`.
3.  **Extraccion de MFA**: Separar la logica de MFA de la de Auth puro.
4.  **Evaluacion de Microservicio**: Una vez alineados, evaluar si `iam` o `mfa` deben ser extraidos a sus propios repositorios segun la carga de trabajo.

## 4. Conclusion
La estructura actual es funcional pero arquitectonicamente confusa. Alinear los contextos con los schemas de base de datos simplificara la navegacion para desarrolladores (humanos e IA) y facilitara una futura migracion a microservicios independientes si fuera necesario.
