# Investigacion: Flujo de Onboarding

**Estado**: Propuesta
**Origen**: Documentacion de Notion (TODO/onboarding)
**Fecha**: 2026-04-25

## Resumen

Diseno del flujo completo de ingreso de usuarios al sistema: desde lead (waitlist) hasta usuario activo con sesion autenticada.

## Flujo General

```
WAITLIST (lead, opcional)
    |  invite
APPLICANT (onboarding obligatorio, 4 pasos)
    |  submit
ADMIN REVIEW (aprobar / rechazar)
    |  approve
USER CREATED (persona con credenciales)
    |  login
AUTH (sesion + tokens)
    |
ACCESO AL PRODUCTO
```

## Entidades del Flujo

### 1. Waitlist (opcional)

Sistema de leads para controlar acceso anticipado. Solo se usa si el producto no esta abierto al publico.

| Campo | Tipo | Descripcion |
|-------|------|-------------|
| `client_name` | String | Nombre del lead |
| `email` | String | Identificador unico (UNIQUE) |
| `status` | Enum | `PENDING`, `ACTIVE`, `INVITED`, `CONVERTED`, `EXPIRED`, `BLOCKED` |
| `source` | String | Origen del lead: `waitlist_form`, `landing_page`, `referral`, `ads`, `partner` |

**Endpoints propuestos**:
- `POST /api/v1/waitlist` — Crear lead
- `GET /api/v1/waitlist/{email}` — Obtener lead
- `POST /api/v1/waitlist/{email}/invite` — Invitar a onboarding
- `POST /api/v1/waitlist/{email}/convert` — Convertir a applicant
- `POST /api/v1/waitlist/{email}/block` — Bloquear lead
- `POST /api/v1/waitlist/expire` — Expirar leads antiguos (batch)

### 2. Applicant (onboarding obligatorio)

Usuario en proceso de validacion. No es usuario del sistema todavia.

| Campo | Tipo | Descripcion |
|-------|------|-------------|
| `email` | String | Identificador |
| `status` | Enum | `IN_PROGRESS`, `SUBMITTED`, `UNDER_REVIEW`, `APPROVED`, `REJECTED`, `BLOCKED`, `EXPIRED`, `ABANDONED` |
| `current_step` | Enum | `PERSONAL_INFO`, `CONTACT_VERIFICATION`, `SET_PASSWORD`, `DOCUMENTS`, `SUBMIT` |
| `personal_info` | JSON | Datos basicos (nombre, pais) |
| `contact_verified` | Boolean | OTP verificado |
| `password_hash` | String | Contrasena (aun no es user) |
| `documents` | Array | Documentos subidos con estado de revision |
| `waitlist_id` | UUID | FK a waitlist (nullable) |

**Pasos del onboarding**:
1. Datos personales → se guardan datos basicos
2. Verificacion de contacto (OTP) → se valida email/telefono
3. Creacion de contrasena → se guarda hash
4. Carga de documentacion → archivos requeridos
5. Submit → status cambia a `SUBMITTED`

**Endpoints propuestos**:
- `POST /api/v1/onboarding/start` — Iniciar onboarding
- `POST /api/v1/onboarding/{id}/personal-info` — Paso 1
- `POST /api/v1/onboarding/{id}/otp/send` — Enviar OTP
- `POST /api/v1/onboarding/{id}/otp/verify` — Verificar OTP
- `POST /api/v1/onboarding/{id}/password` — Paso 3
- `POST /api/v1/onboarding/{id}/documents` — Paso 4 (multipart)
- `POST /api/v1/onboarding/{id}/submit` — Enviar a revision

### 3. Admin Review

Panel de administracion para evaluar applicants y gestionar waitlist.

**Endpoints propuestos (admin)**:
- `GET /api/v1/admin/applicants?status=under_review` — Listar applicants
- `POST /api/v1/admin/applicants/{id}/approve` — Aprobar (crea user)
- `POST /api/v1/admin/applicants/{id}/reject` — Rechazar (con razon)
- `POST /api/v1/admin/applicants/{id}/request-info` — Solicitar mas informacion
- `POST /api/v1/admin/applicants/{id}/documents/{doc_id}/approve` — Aprobar documento
- `POST /api/v1/admin/applicants/{id}/documents/{doc_id}/reject` — Rechazar documento

**Roles de admin propuestos**: `reviewer`, `admin`, `super_admin`

### 4. User (entidad final)

Solo se crea tras aprobacion del applicant. Es la entidad estable del sistema.

| Campo | Tipo | Descripcion |
|-------|------|-------------|
| `status` | Enum | `ACTIVE`, `SUSPENDED`, `BLOCKED`, `PENDING_VERIFICATION`, `DELETED` |
| `applicant_id` | UUID | FK a applicant original |
| `is_active` | Boolean | Control de acceso |

### 5. Auth (sesion y tokens)

Capa de autenticacion. Solo opera sobre users existentes y aprobados.

**Metodo recomendado**: JWT + Refresh Token
- Access token corto (15 min)
- Refresh token largo (7-30 dias)

**Endpoints propuestos**:
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/refresh`
- `POST /api/v1/auth/logout`
- `GET /api/v1/auth/me`
- `POST /api/v1/auth/forgot-password`
- `POST /api/v1/auth/reset-password`

### 6. Auth Error Handling

Respuestas de error con dos niveles: HTTP status code + internal code.

| HTTP | Internal Code | Significado |
|------|:------------:|-------------|
| 401 | 10 | Sesion no iniciada |
| 401 | 11 | Token expirado |
| 401 | 12 | Token invalido |
| 401 | 13 | Usuario bloqueado |
| 401 | 14 | Refresh token invalido o revocado |
| 401 | 15 | Sesion revocada (logout global) |
| 403 | 20 | Sin permisos para este recurso |
| 403 | 21 | Rol insuficiente |
| 403 | 22 | Scope no permitido |
| 400 | 30 | Email invalido |
| 400 | 31 | Password debil |
| 400 | 32 | OTP incorrecto |
| 400 | 33 | Datos incompletos |

## Reglas de Negocio Criticas

1. Todos los usuarios DEBEN pasar por Applicant antes de convertirse en User
2. No se puede crear un user sin aprobacion de admin
3. Auth solo funciona para users con status `ACTIVE`
4. Applicant no es un usuario incompleto — es un estado previo separado
5. Waitlist es opcional (solo para acceso controlado)
6. Los documentos pueden rechazarse individualmente
7. Un applicant rechazado puede re-enviar (resubmit)

## Arquitectura Multi-App

```
                AUTH CENTRAL
                    |
    +---------------+---------------+
    |               |               |
ADMIN APP     DOCTOR APP     PATIENT APP
    |               |               |
    +---------------+---------------+
                    |
              AUDIT / LOGS
```

## Decisión de Arquitectura (ADR 004)

Se ha seleccionado el **Enfoque B (Person-first)** y el almacenamiento de **Waitlist en MongoDB**.

1.  **Waitlist (Mongo)**: Los leads se almacenan en una colección de MongoDB por su flexibilidad de esquema.
2.  **Transición**: Al iniciar onboarding, se crea una `person` en Postgres con `verification_status = 'PENDING'`.
3.  **Reutilización**: Se usan los schemas existentes de `mfa`, `expedient` y `auth` directamente sobre el `id_person` creado.
4.  **Aprobación**: El cambio a `APPROVED` habilita el acceso completo al sistema.

## Próximos Pasos (Tasks)

Con la decisión tomada en [ADR 004](../decisions/004-onboarding-approach-and-waitlist-storage.md), se pueden proceder a crear las tareas de implementación:

1.  **TASK-002**: Implementación del microservicio de Waitlist (MongoDB).
2.  **TASK-003**: Creación de la lógica de "Promoción de Lead" (Mongo -> Postgres).
3.  **TASK-004**: Adaptación de los endpoints de `people` y `auth` para soportar el flujo de onboarding.
4.  **TASK-005**: Panel de administración para revisión y aprobación de Applicants (Personas PENDING).
