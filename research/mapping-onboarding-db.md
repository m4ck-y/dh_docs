# Mapeo de Datos: Onboarding Flow a Base de Datos

Este documento detalla la correspondencia entre los endpoints del flujo de onboarding y las columnas especificas de las bases de datos (PostgreSQL y MongoDB).

## 1. Waitlist (MongoDB)

| Endpoint | Coleccion | Campos (Schema flexible) |
|----------|-----------|--------------------------|
| `POST /api/v1/waitlist` | `waitlist` | `client_name`, `email`, `source`, `status: 'ACTIVE'`, `timestamps.created_at` |
| `POST /api/v1/admin/waitlist/{email}/invite` | `waitlist` | `status: 'INVITED'`, `onboarding.invite_token`, `onboarding.token_expires_at`, `timestamps.invited_at` |

## 2. Onboarding Core (PostgreSQL)

Basado en el **Enfoque B (Person-first)**: la creacion de la entidad central ocurre al inicio del proceso.

### Paso 0: Inicio de Onboarding
**Endpoint**: `POST /api/v1/onboarding/start`

| Tabla | Columna | Valor / Origen |
|-------|---------|----------------|
| `people.person` | `id` | Generado (UUID) |
| `people.person` | `verification_status` | `'PENDING'` |
| `people.email` | `id_person` | `person.id` |
| `people.email` | `email` | Desde el lead de Waitlist |
| `people.email` | `type_email` | `PERSONAL` (Enum EEmailType) |
| `auth.user` | `id_person` | `person.id` |
| `auth.user` | `is_active` | `true` (permitir flujo, pero restringido por person.status) |

### Paso 1: Datos Personales
**Endpoint**: `POST /api/v1/onboarding/{id}/personal-info`

| Tabla | Columna | Valor / Origen |
|-------|---------|----------------|
| `people.person` | `first_name` | Input usuario |
| `people.person` | `last_name` | Input usuario |
| `people.person` | `second_last_name` | Input usuario |
| `people.birth` | `id_person` | `person.id` |
| `people.birth` | `birth_date` | Input usuario |
| `people.birth` | `key_birth_country` | Input usuario (FK catalog) |

### Paso 2: Verificacion OTP
**Endpoints**: `/otp/send` y `/otp/verify`

| Tabla | Columna | Valor / Origen |
|-------|---------|----------------|
| `mfa.otp_challenge` | `id_person` | `person.id` |
| `mfa.otp_challenge` | `code_hash` | Generado por sistema |
| `mfa.otp_challenge` | `destination` | Email o Telefono donde se envio el codigo |
| `mfa.otp_challenge` | `channel` | `'EMAIL'` o `'SMS'` (Enum EOtpChannel) |
| `mfa.otp_challenge` | `purpose` | `'LOGIN'` o `'SENSITIVE_ACTION'` (Enum EOtpPurpose) |

### Paso 3: Credenciales
**Endpoint**: `POST /api/v1/onboarding/{id}/password`

| Tabla | Columna | Valor / Origen |
|-------|---------|----------------|
| `auth.user` | `password_hash` | Hash de la contrasena (Argon2/Bcrypt) |

### Paso 4: Documentacion
**Endpoint**: `POST /api/v1/onboarding/{id}/documents`

| Tabla | Columna | Valor / Origen |
|-------|---------|----------------|
| `expedient.document` | `id_person` | `person.id` |
| `expedient.document` | `id_document_type` | Input (identificacion, comprobante, etc.) |
| `expedient.document` | `url` | Path en Storage (S3/MinIO) |
| `expedient.document` | `verification_status` | `'PENDING'` (Enum EVerificationStatus) |

## 3. Administracion y Aprobacion (PostgreSQL)

### Evaluacion de Documentos
**Endpoint**: `POST /api/v1/admin/applicants/{id}/documents/{doc_id}/approve`

| Tabla | Columna | Valor / Origen |
|-------|---------|----------------|
| `expedient.document` | `verification_status` | `'APPROVED'` o `'REJECTED'` |

### Aprobacion Final (Promocion)
**Endpoint**: `POST /api/v1/admin/applicants/{id}/approve`

| Tabla | Columna | Valor / Origen |
|-------|---------|----------------|
| `people.person` | `verification_status` | `'APPROVED'` |
| `iam.membership` | `id_person` | `person.id` |
| `iam.membership` | `id_role` | Rol asignado (ej: PATIENT, DOCTOR) |

## 4. Auditoria y Trazabilidad (MongoDB/Logs)

| Evento | Almacenamiento | Datos |
|--------|----------------|-------|
| Onboarding completado | `mongo.waitlist` | `status: 'CONVERTED'`, `onboarding.person_id_postgres: UUID` |
| Intento de registro | `auth.login_attempt` | `id_person`, `status: 'SUCCESS'/'FAILED'`, `ip_address` |
