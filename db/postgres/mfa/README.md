# mfa

Schema de PostgreSQL para autenticacion multifactor.

Gestiona factores de autenticacion adicionales (TOTP, SMS, email), desafios OTP temporales y codigos de recuperacion de emergencia.

## Entidades

| Entidad | Descripcion |
|---|---|
| `auth_factor` | Metodo MFA habilitado por persona (TOTP, SMS, email, recovery code) |
| `otp_challenge` | Desafio OTP temporal generado en tiempo real para verificacion |
| `recovery_code` | Codigos de respaldo de emergencia (single-use) |

## Enums

| Enum | Valores |
|---|---|
| `EFactorType` | `TOTP`, `SMS`, `EMAIL`, `RECOVERY_CODE` |
| `EOtpChannel` | `SMS`, `EMAIL`, `TOTP` |
| `EOtpPurpose` | `LOGIN`, `RESET_PASSWORD`, `SENSITIVE_ACTION` |

## Dependencias externas

| Schema | Tabla | Uso |
|--------|-------|-----|
| `people` | `person` | Todas las entidades referencian `person` via `id_person FK` |

## Archivos

| Archivo | Descripcion |
|---|---|
| [erd.mmd](./erd.mmd) | Diagrama ERD del schema en Mermaid |