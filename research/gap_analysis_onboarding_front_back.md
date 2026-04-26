# Investigación: Análisis de Compatibilidad — dh_onboarding_front vs dh_onboarding_back

**Estado**: Investigación
**Fecha**: 2026-04-26
**Relacionado con**: TASK-003 (Implementación Microservicio de Onboarding)

---

## 1. Flujo actual del frontend (pasos capturados)

El frontend implementa **9 pasos** de registro en `VistaRegistro`:

| Paso | Componente | Datos capturados |
|---|---|---|
| 1 | `PasoRegistroCuenta` | correo, lada, teléfono, contraseña, confirmar contraseña, rol (médico/paciente) |
| 2 | `PasoSeleccionEnvioCodigo` | canal OTP (correo / SMS) |
| 3 | `PasoCodigoVerificacion` | código OTP de 6 dígitos |
| 4 | `PasoSeleccionCapturaPerfil` | foto de perfil (cámara o archivo) |
| 5 | `PasoDatosPersonales` | CURP, nombre, apellido paterno, apellido materno, fecha nacimiento, sexo |
| 6 | `PasoDomicilio` | CP, colonia, estado, municipio, ciudad, calle, No. ext, No. int, referencia |
| 7 | `PasoCargaDocumentos` | INE (PDF), comprobante de domicilio (PDF) |
| 8 | `PasoConfirmacionPerfil` | revisión de datos antes de enviar |
| 9 | `PasoConfirmacionCuenta` | confirmación final |

---

## 2. Endpoints que llama el frontend

El frontend apunta a **dos bases de URL** independientes (`VITE_API_PREREGISTRO_URL`, `VITE_API_SESION_URL`), **no a `dh_onboarding_back`**.

### Endpoints de preregistro (`VITE_API_PREREGISTRO_URL`)

| Endpoint | Método | Body | Propósito |
|---|---|---|---|
| `/preregistro/preregistro/enviar-codigo-correo/` | POST | `{identificador: email}` | Enviar OTP al correo |
| `/preregistro/preregistro/validar-correo/` | POST | `{identificador: email, codigo: string}` | Validar código OTP |
| `/preregistro/preregistro/reenviar-codigo/` | POST | `{identificador: email}` | Reenviar OTP |
| `/preregistro/preregistro/registro/` | POST | `{rol, correo, telefono, code_telefono, contrasena}` | Crear cuenta |

### Endpoints de sesión (`VITE_API_SESION_URL`)

| Endpoint | Método | Body | Propósito |
|---|---|---|---|
| `/preregistro/curp/extraer/{curp}` | GET | — | Extraer datos de CURP (actualmente deshabilitado) |
| `/preregistro/curp/subir` | POST | `DatosPersonales` | Guardar datos personales |
| `/preregistro/direccion/guardar` | POST | `DomicilioData` | Guardar domicilio |
| `/preregistro/ine/subir-pdf` | POST | `FormData {file}` | Subir INE en PDF |
| `/preregistro/comprobante/subir` | POST | `FormData {file}` | Subir comprobante de domicilio |
| `/auth/token` | POST | — | Login |
| `/auth/me` | GET | — | Usuario actual |
| `/auth/logout` | POST | — | Logout |
| `/auth/refresh-token` | POST | — | Renovar token |

---

## 3. Mapeo de campos frontend → base de datos PostgreSQL

### Paso 1 — Registro de cuenta

| Campo frontend | Tabla PostgreSQL | Campo DB | Notas |
|---|---|---|---|
| `correo` | `people.email` | `email` | `type_email: PERSONAL` |
| `lada` + `telefono` | `people.phone` | `code` + `number` | `type_phone: MOBILE` |
| `contrasena` | `auth.user` | `password_hash` | Hash Argon2/Bcrypt |
| `rol` (médico=0 / paciente=1) | `iam.membership` | `id_role` | Solo se asigna tras aprobación |

### Paso 5 — Datos personales

| Campo frontend | Tabla PostgreSQL | Campo DB | Notas |
|---|---|---|---|
| `nombre` | `people.person` | `first_name` | |
| `apellidoPaterno` | `people.person` | `last_name` | |
| `apellidoMaterno` | `people.person` | `second_last_name` | |
| `sexo` (H/M/X) | `people.person` | `type_gender` (EGenderIdentity) | Ver gap #3 |
| `fechaNacimiento` | `people.birth` | `birth_date` | |
| `nacionalidad` | `people.legal_info` | `key_nationality` FK | Catalog FK — ver gap #4 |
| `entidadNacimiento` | `people.birth` | `key_state_birth` FK | Catalog FK — ver gap #4 |
| `curp` | `people.personal_identifier` | `identifier_value` | `id_identifier_type: NATIONAL_ID` |

### Paso 6 — Domicilio

| Campo frontend | Tabla PostgreSQL | Campo DB | Notas |
|---|---|---|---|
| `codigoPostal` | `people.address` | `postal_code` | |
| `colonia` | `people.address` | `key_colony` FK | String → FK catalog — ver gap #5 |
| `estado` | `people.address` | `key_state` FK | String → FK catalog — ver gap #5 |
| `municipio` | `people.address` | `key_municipality` FK | String → FK catalog — ver gap #5 |
| `calle` + `numeroExterior` | `people.address` | `address` | Concatenar |
| `numeroInterior` | `people.address` | `address_complement` | |
| `referencia` | — | — | Sin campo directo en DB — ver gap #6 |

### Paso 7 — Documentos

| Campo frontend | Tabla PostgreSQL | Campo DB | Notas |
|---|---|---|---|
| INE (PDF) | `expedient.document` | `url` | `verification_status: PENDING` |
| Comprobante | `expedient.document` | `url` | `verification_status: PENDING` |

---

## 4. Brechas y conflictos detectados (Gaps)

### Gap #1 — Flujo incompatible: registro abierto vs. token de invitación

**Crítico.** El frontend implementa registro libre (cualquier usuario puede iniciar). El sistema de backend definido en ADR 004 requiere un `invite_token` proveniente de la waitlist para iniciar el onboarding.

**Opciones:**
- **A)** Adaptar el frontend para leer el token del URL (`?token=xxx`) antes del paso 1
- **B)** Hacer el token opcional en `POST /v1/onboarding/start` — si no hay token, es registro libre

### Gap #2 — Los endpoints del frontend no existen en dh_onboarding_back

El frontend llama a `/preregistro/preregistro/...` y `/preregistro/curp/...`. Ninguna de estas rutas existe en `dh_onboarding_back`. Requiere:
- Mapear los endpoints del frontend a la nueva estructura de rutas
- O actualizar el frontend para apuntar a `dh_onboarding_back`

### Gap #3 — Mapeo de sexo (H/M/X → EGenderIdentity)

**Dónde está la discrepancia:**

- Frontend — opciones definidas en:
  `dh_onboarding_front/src/shared/data/camposDatosPersonales.ts` **líneas 32–40**
  ```ts
  { valor: 'H', etiqueta: 'Hombre' },
  { valor: 'M', etiqueta: 'Mujer' },
  { valor: 'X', etiqueta: 'No binario' },
  ```

- DB — enum definido en:
  `docs/db/postgres/people/erd.mmd` **líneas 41–50**
  ```
  MASCULINO "1" · FEMENINO "2" · NO_ESPECIFICADO "0" · OTRO "88"
  ```

`X` (No binario) no tiene equivalente directo. Candidatos: `NO_ESPECIFICADO=0` o `OTRO=88`. Requiere decisión de negocio.

---

### Gap #4 — Campos de catálogo geográfico (nacionalidad, entidad de nacimiento)

**Dónde está la discrepancia:**

- Frontend — campos declarados como `string` en:
  `dh_onboarding_front/src/domain/types.ts` **líneas 83–84** (interface `DatosPersonales`)
  ```ts
  nacionalidad: string
  entidadNacimiento: string
  ```

- DB — esperan FK a catálogo en:
  `docs/db/postgres/people/erd.mmd` **líneas 235–241** (entidad `legal_info`) y **líneas 237–241** (entidad `birth`)
  ```
  legal_info.key_nationality FK
  birth.key_state_birth FK
  ```

Requiere endpoint de catálogo o mapeo nombre → clave antes de persistir.

---

### Gap #5 — Dirección: strings vs. claves de catálogo

**Dónde está la discrepancia:**

- Frontend — campos declarados como `string` en:
  `dh_onboarding_front/src/domain/types.ts` **líneas 93–103** (interface `DomicilioData`)
  ```ts
  colonia: string
  estado: string
  municipio: string
  ciudad: string
  ```

- DB — esperan FK a catálogo en:
  `docs/db/postgres/people/erd.mmd` **líneas 184–188** (entidad `address`)
  ```
  address.key_state FK
  address.key_municipality FK
  address.key_colony FK
  ```

El endpoint `GET /codigos_postales?codigo_postal=...` (`api-routes.ts` **línea 10**) ya devuelve `{nombre, municipio, estado, ciudad}` — falta definir cómo se convierten en claves de catálogo.

---

### Gap #6 — Campo `referencia` → `address_complement`

`referencia` del frontend (`types.ts` **línea 102**) se mapea a `address_complement` en la DB (`erd.mmd` **línea 189**). Sin brecha — solo requiere documentar el mapeo explícito en el backend.

---

### Gap #7 — CURP actualmente deshabilitado en el frontend

**Dónde está:**
`dh_onboarding_front/src/application/services/RegistrationService.ts` **línea 13**
```ts
const OMITIR_VALIDACION_Y_GUARDADO_CURP = true
```

La validación y guardado del CURP están desactivados. El backend debe tratar el CURP como opcional en esta versión. Cuando se reactive, el dato va a:
`people.personal_identifier.identifier_value` con `id_identifier_type: NATIONAL_ID` (`erd.mmd` **líneas 271–279**).

---

### Gap #8 — Foto de perfil sin endpoint en backend

**Dónde está:**
- Frontend — paso definido en `PasoSeleccionCapturaPerfil.tsx` (captura con cámara o archivo)
- DB — campo destino: `people.person.url_photo` (`erd.mmd` **línea 150**)
- Backend — no existe ningún endpoint de upload en `dh_onboarding_back`

Requiere endpoint de upload + integración con storage (GCS / S3 / MinIO).

---

### Gap #9 — Rol enviado al registrar vs. asignado tras aprobación

**Dónde está la discrepancia:**

- Frontend — envía `rol` en el body de registro:
  `dh_onboarding_front/src/domain/types.ts` **líneas 235–241** (interface `RegisterUserData`)
  ```ts
  rol: number   // médico=0, paciente=1
  ```
  `dh_onboarding_front/src/application/services/RegistrationService.ts` **líneas 33–35**
  ```ts
  getBackendRole(profileType: string): number {
    return profileType === 'medico' ? 0 : 1
  }
  ```
  `dh_onboarding_front/src/infrastructure/repositories/HttpPreregistroRepository.ts` **líneas 42–49** — `rol` incluido en POST `/registro/`

- Backend — según ADR 004, el rol se asigna en `iam.membership` **solo tras aprobación del admin**, no durante el registro.

El backend debe ignorar el campo `rol` en el registro inicial y solo usarlo como referencia al aprobar el applicant.

---

## 5. Endpoints que necesita implementar dh_onboarding_back

Basado en el flujo del frontend y la DB:

| Endpoint propuesto | Equivalente frontend (legacy) | Propósito |
|---|---|---|
| `POST /v1/onboarding/start` | (nuevo — con o sin token) | Crear `Person` PENDING, `email`, `phone`, `auth.user` |
| `POST /v1/onboarding/{id}/otp/send` | `enviar-codigo-correo` | Genera OTP y llama a PulseCore |
| `POST /v1/onboarding/{id}/otp/verify` | `validar-correo` | Valida OTP en `mfa.otp_challenge` |
| `POST /v1/onboarding/{id}/personal-info` | `curp/subir` | Guarda `person`, `birth`, `legal_info`, `personal_identifier` |
| `POST /v1/onboarding/{id}/address` | `direccion/guardar` | Guarda `people.address` |
| `POST /v1/onboarding/{id}/password` | (implícito en `/registro/`) | Actualiza `auth.user.password_hash` |
| `POST /v1/onboarding/{id}/documents` | `ine/subir-pdf` + `comprobante/subir` | Crea `expedient.document` — ver detalle abajo |
| `POST /v1/onboarding/{id}/submit` | `PasoConfirmacionCuenta` | Cambia status a `SUBMITTED` |

### Unificación de uploads de documentos

Los dos endpoints legacy (`ine/subir-pdf` y `comprobante/subir`) se unifican en un solo endpoint nuevo especificando el tipo de documento via `id_document_type`.

Esto es posible porque el schema de `expedient` define los tipos como un **catálogo configurable** (tabla `document_type` con `name` libre), no como un enum fijo:

```
docs/db/postgres/expedient/erd.mmd — líneas 39–45
document_type { UUID id PK · String name · UUID id_category FK }
document       { UUID id_document_type FK · String url_file · ... }
```

**Mapeo legacy → nuevo:**

| Endpoint legacy | `document_type.name` sugerido | Categoría |
|---|---|---|
| `POST /preregistro/ine/subir-pdf` | `PERSONAL_ID` | Identificación |
| `POST /preregistro/comprobante/subir` | `PROOF_OF_ADDRESS` | Domicilio |

**Body del nuevo endpoint (multipart/form-data):**
```
file:             archivo binario
id_document_type: UUID del tipo en el catálogo
```

El frontend puede obtener los `id_document_type` disponibles desde un endpoint de catálogo:
```
GET /v1/catalogs/document-types?category=onboarding
```
que devuelve los tipos requeridos para el proceso de registro.

---

## 6. Siguientes pasos recomendados

1. Decidir Gap #1 (token obligatorio o registro libre)
2. Decidir Gap #3 (mapeo sexo X)
3. Definir estrategia de catálogos geográficos (Gap #4 y #5)
4. Implementar `POST /v1/onboarding/start` como primer endpoint de TASK-003
5. Actualizar el frontend para apuntar a `dh_onboarding_back` como `VITE_API_PREREGISTRO_URL`
