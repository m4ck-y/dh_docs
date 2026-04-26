# Flujo de Onboarding — Digital Hospital

Panorama general del ciclo completo desde que un interesado se registra en la lista de espera hasta que accede al sistema como usuario activo.

> Documentación detallada por etapa en los archivos numerados de esta carpeta.

---

## Flujo General

```
WAITLIST (lead, opcional)
    │  Admin invita
    ▼
APPLICANT (onboarding obligatorio, 4 pasos)
    │  Submit
    ▼
ADMIN REVIEW (aprobar / rechazar)
    │  Approve
    ▼
USUARIO ACTIVO (Person con credenciales)
    │  Login
    ▼
AUTH (sesión + tokens JWT)
    │
    ▼
ACCESO AL PRODUCTO
```

---

## Servicios involucrados

| Servicio | Rol |
|---|---|
| `dh_onboarding_back` | Orquestador — waitlist, onboarding, validación de token |
| `app_message_sender` (PulseCore) | Envío de emails: confirmación, invitación, OTP, bienvenida |
| `api_core` | Entidades base: Person, IAM, MFA, Expediente |
| `app_auth` | Credenciales y sesiones JWT |
| `app_logger_tracer` (VitalTrace) | Observabilidad — logs y eventos de cada acción |

---

## Etapas y entidades clave

### 1. Waitlist
Lead interesado. Almacenado en **MongoDB** (`dh_onboarding_back`).

| Campo | Descripción |
|---|---|
| `client_name` | Nombre del lead (persona o empresa) |
| `email` | Identificador único |
| `status` | `ACTIVE` → `INVITED` → `CONVERTED` / `BLOCKED` / `EXPIRED` |
| `source` | Origen: `landing_page`, `referral`, `ads`, `partner`, `waitlist_form` |
| `onboarding.invite_token` | Token seguro generado al invitar |
| `onboarding.token_expires_at` | Expiración del token (7 días) |
| `onboarding.person_id_postgres` | UUID del Person creado al convertir |

### 2. Applicant
Lead que inició el onboarding. Almacenado como `people.person` en **PostgreSQL** con `verification_status: PENDING`.

| Campo | Descripción |
|---|---|
| `email` | Identificador |
| `verification_status` | `PENDING` → `SUBMITTED` → `APPROVED` / `REJECTED` |
| `current_step` | `PERSONAL_INFO` → `CONTACT_VERIFICATION` → `SET_PASSWORD` → `DOCUMENTS` → `SUBMIT` |

### 3. Usuario activo
Solo se crea tras aprobación del admin.
- `people.person.verification_status` → `APPROVED`
- `iam.membership` creado con el rol asignado

---

## Reglas de negocio críticas

1. Todo usuario DEBE pasar por Applicant antes de convertirse en User.
2. No se puede crear un user sin aprobación explícita del admin.
3. Auth solo funciona para users con `verification_status: APPROVED`.
4. El invite_token es de un solo uso y expira en 7 días.
5. Los documentos pueden rechazarse individualmente.
6. Un applicant rechazado puede re-enviar (resubmit).
7. Waitlist es opcional — solo para acceso controlado al producto.

---

## Arquitectura del onboarding

```
dh_onboarding_back
    ├── contexts/waitlist/     ← MongoDB (Beanie)
    └── contexts/onboarding/   ← Orquesta llamadas a api_core + app_auth
             │
             ▼
        api_core (PostgreSQL)
        ├── people.person
        ├── people.birth
        ├── people.email
        ├── mfa.otp_challenge
        ├── auth.user
        ├── expedient.document
        └── iam.membership
```

---

## Notificaciones por etapa

| Etapa | Trigger | Endpoint PulseCore |
|---|---|---|
| Lead se registra | Automático | `POST /v1/waitlist/confirmation` |
| Admin invita lead | Automático | `POST /v1/waitlist/invite` |
| Paso de OTP | Automático | `POST /v1/otp` (`purpose: SENSITIVE_ACTION`) |
| Admin aprueba | Manual post-aprobación | `POST /v1/notifications/welcome` |
| Recuperar contraseña | Automático | `POST /v1/otp` (`purpose: RESET_PASSWORD`) |

---

## Documentación detallada

- [1. Waitlist](1.waitlist.md) — Registro y gestión de leads, endpoints admin
- [2. Onboarding](2.onboarding.md) — Los 4 pasos de registro, validación de token
- [3. Admin Review](3.admin-review.md) — Revisión de documentos, aprobación/rechazo
- [4. Auth](4.auth.md) — Login, MFA, refresh, recuperación de contraseña
