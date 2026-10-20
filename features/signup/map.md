# Mapa de datos — signup

Diccionario del formulario de autorregistro: **qué captura el front** y **dónde se
guarda**. Fuente del front: `frontend/dh_frontend_signup/src/domain/schemas.ts`
(origen) y los ERDs por esquema (destino).

**Completitud:** los **41 campos** del front están inventariados ✓; de ellos **3 no
tienen destino** ✗ y **8 tienen algún desajuste** (parcial, dato perdido, catálogo
faltante, semántica o duplicidad) ✗ — ver [Gaps](#gaps). Otros **4 son efímeros o
derivados** por diseño ✓.

## Cómo se lee

| Columna | Regla |
|---|---|
| **Campo (front)** | nombre tal cual lo usa el front (`schemas.ts`) |
| **Destino BD** | `schema.tabla.columna` (PostgreSQL) o `base.colección.campo` (MongoDB); `—` = 🔴 sin destino |
| **Type** | tipo **en BD** (`String(n)` · `Date` · `Bool` · `Int FK` · `Enum(E…)` · `UUID`) |
| **Description** | para qué es + `[posibles valores]` + constraints (`unique`, longitud, `CHECK`) |
| **¿Obligatorio?** | lo que exige **el front** (zod); si la BD difiere se marca 🔴 |

Convenciones: los sentinels de la UI (*"Prefiere no decirlo"*, *"Ninguna"*, *"Otro"*)
se guardan como `NULL` en el dominio ([ADR 044](../../decisions/044-catalogos-gobernados.md));
las referencias a catálogos cruzan motor como `key_*` y dentro de PostgreSQL como
`id_*` ([ADR 049](../../decisions/049-referencia-catalogos-id-vs-key.md)).

---

## Cuenta (paso previo)

| Campo (front) | Destino BD | Type | Description | ¿Obligatorio? |
|---|---|---|---|---|
| `correo` | `auth.user.username` | `String` | Identidad de login (= el correo). **unique** · 🔴 definir si además se guarda en `people.email` | sí |
| `contrasena` | `auth.user.password_hash` | `String` | Nunca en claro. `[8+ · 1 mayúscula · 1 dígito · 1 especial]` | sí |
| `confirmarContrasena` | — | — | Solo validación en el front ✗ | sí |
| `aceptaTerminos` | `dh_legal.legal_acceptances` (`key=TERMS`) | `Bool` → evento | No se guarda el texto ni un booleano: evento con `version` + `hash` ([ADR 050](../../decisions/050-contenido-legal-en-mongodb.md)) | sí |
| `codigo` (`VerifyOtpView`) | `dh_mfa.otp_challenges` | `String` (Mongo) | Verificación del destino (efímero, append-only) · 🔴 el esquema PG `mfa.otp_challenge` duplica esto | sí |

## Datos personales

| Campo (front) | Destino BD | Type | Description | ¿Obligatorio? |
|---|---|---|---|---|
| `nombre` | `people.person.first_name` | `String` | Se prellena desde el CURP | sí |
| `apellidoPaterno` | `people.person.last_name` | `String` | — | sí |
| `apellidoMaterno` | `people.person.second_last_name` | `String` | — | sí |
| `curp` | `people.personal_identifier.identifier_value` | `String` | `id_identifier_type = NATIONAL_ID` · `[A-Z0-9]{18}` · 🔴 no existe columna `person.curp` | sí |
| `fechaNacimiento` | `people.birth.birth_date` | `Date` | Se prellena desde el CURP | sí |
| `lugarNacimiento` | `people.birth.key_birth_country` · `key_state_birth` | `String(20) FK` | 🔴 el front captura **ciudad** y el modelo no tiene municipio de nacimiento | sí |
| `sexoNacimiento` | `health_profile.biological_profile.type_biological_sex` | `Enum(EBiologicalSex)` | `[MALE · FEMALE · INTERSEXUAL]` · *"Prefiere no decirlo"* → `NULL` · 🔴 revisar `people.legal_info.type_national_id_sex` (String) | sí |
| `telefonoPrincipal` | `people.phone.number` | `String(10)` | `code = +52` y `type_phone = MOBILE` los rellena el backend · 🔴 el modelo no tiene `is_primary` | sí |
| `telefonoOtro` | `people.phone.number` (2ª fila) | `String(10)` | 🔴 sin `is_primary` solo se distingue por orden | no |
| `parentesco` | `relationships.person_responsible.id_relationship` | `Int FK` | Catálogo `relationship` (solo flujo *asociado*); el tutor además es una fila de `people.person` | condicional |

## Domicilio

| Campo (front) | Destino BD | Type | Description | ¿Obligatorio? |
|---|---|---|---|---|
| `codigoPostal` | `people.address.postal_code` | `String(10)` | `[5 dígitos]`; alimenta el selector de colonias (catálogo masivo) | sí |
| `estado` | `people.address.key_state` | `String(20) FK` | `key_*` cross-motor (ADR 049) | sí |
| `municipio` | `people.address.key_municipality` | `String(20) FK` | idem | sí |
| `colonia` | `people.address.key_colony` | `String(20) FK` | idem (`coloniaNombre` es solo el label ✗) | sí |
| `calle` | `people.address.address` | `String(191)` | Vía y número | no |
| `numeroExterior` | `people.address.address_complement` | `String(191)` | 🔴 exterior e interior fusionados en un campo | no |
| `numeroInterior` | `people.address.address_complement` | `String(191)` | 🔴 idem | no |
| `referencias` | — | — | 🔴 sin destino | no |
| `viveContigo` | — | — | 🔴 sin destino (solo flujo *asociado*): "mismo domicilio que el tutor" no se guarda | condicional |
| `coloniasDisponibles` | — | — | Efímero: opciones del selector ✗ | no |

## Información complementaria

| Campo (front) | Destino BD | Type | Description | ¿Obligatorio? |
|---|---|---|---|---|
| `genero` | `people.person.id_gender` | `Int FK` | Catálogo `gender` · *"Prefiere no decirlo"* → `NULL` | sí |
| `generoEspecificacion` | — (ítem nuevo del catálogo) | — | Solo si `genero = otro`: crea el ítem y se guarda su `id` | condicional |
| `religion` | `people.sociocultural_identity.id_religion` | `Int FK` | Catálogo `religion` · *"Ninguna"* / *"Prefiere no decirlo"* → `NULL` | sí |
| `religionEspecificacion` | — (ítem nuevo del catálogo) | — | Solo si `religion = otra` | condicional |
| `orientacion` | `people.sociocultural_identity.id_orientation` | `Int FK` | Catálogo `orientation` | sí |
| `orientacionEspecificacion` | — (ítem nuevo del catálogo) | — | Solo si `orientacion = otra` | condicional |
| `estadoCivil` | `people.legal_info.civil_status` | `Enum(ECivilStatus)` | `[SINGLE · MARRIED · COMMON_LAW · SEPARATED · DIVORCED · WIDOWED]` · sentinel → `NULL` | sí |
| `escolaridad` | `people.profile.education_level` | `Enum(EEducationLevel)` | `[NO_STUDIES · PRIMARY · SECONDARY · HIGH_SCHOOL · UNIVERSITY · POSTGRADUATE]` · sentinel → `NULL` | sí |
| `ocupacion` | `people.profile.id_occupation` | `Int FK` | Catálogo `occupation` | sí |
| `ocupacionEspecificacion` | — (ítem nuevo del catálogo) | — | Solo si `ocupacion = otro` | condicional |
| `discapacidad` | `health_profile.person_disability.type_disability` | `Enum(EDisabilityType)` | `[PHYSICAL · SENSORY · INTELLECTUAL · PSYCHOSOCIAL · MULTIPLE]` · *"Ninguna"* / *"Prefiere no decirlo"* → sin filas | sí |
| `sangre` | `health_profile.biological_profile.type_blood_type` | `Enum(EBloodType)` | `[A+ · A- · B+ · B- · AB+ · AB- · O+ · O-]` · sentinel → `NULL` | sí |
| `lenguaIndigena` | `people.sociocultural_identity.self_considers_indigenous` | `Bool` | 🔴 el front pregunta *"¿habla lengua indígena?"* y el modelo *"¿se considera indígena?"* | sí |
| `lenguaIndigenaNombre` | `people.sociocultural_identity.key_indigenous_language` | `String(20) FK` | 🔴 el front trae lista estática (`indigenousLanguages.ts`): falta el catálogo (ADR 044) | condicional |

## Contacto de emergencia

| Campo (front) | Destino BD | Type | Description | ¿Obligatorio? |
|---|---|---|---|---|
| `contactos[]` | `people.emergency_contact` (una fila por contacto) | — | `1..2` contactos (el front corta en 2) | sí |
| `nombre` | `people.emergency_contact.first_name` · `last_name` | `String` | Snapshot del contacto: **no** es una fila de `person` | sí |
| `parentesco` | `people.emergency_contact.id_relationship` | `Int FK` | Catálogo `relationship` | sí |
| `parentescoEspecificacion` | — (ítem nuevo del catálogo) | — | Solo si `parentesco = otro` | condicional |
| `telefonoPrincipal` | `people.emergency_contact.phone_number` | `String` | — | sí |
| `telefonoOtro` | — | — | 🔴 sin destino: el modelo guarda un solo teléfono del contacto | no |
| `id` | — | — | Efímero: clave de la lista en la UI ✗ | sí |
| — | `people.emergency_contact.id_user_owner` | `Int FK` | 🔴 lo debe llenar el backend (`auth.user.id` del titular) | — |
| — | `people.emergency_contact.email` · `notes` | `String` · `Text` | 🔴 el front no los captura | — |

---

## Lo que no se guarda (efímero o derivado)

`confirmarContrasena` (solo validación) · `coloniasDisponibles` (opciones del selector) ·
`id` de la lista de contactos (UI) · `edad` (derivada de `birth_date`; la captura el
pre-registro) · el **texto** de los términos (archivo en object storage, ADR 050) ·
la **contraseña** en claro (solo el `password_hash`).

## Lo que rellena el backend (el front no lo pregunta)

`people.phone.code = +52` · `type_phone = MOBILE` · `type_address = HOME` ·
`email.type_email = PERSONAL` · `key_country = MX` · `person.verification_status = PENDING` ·
`uuid` y auditoría del BaseModel · `emergency_contact.id_user_owner`.

## Gaps

| # | Gap | Tipo | Estado |
|---|---|---|---|
| G1 | `referencias` (domicilio) — sin columna | sin destino | 🔴 |
| G2 | 2º teléfono del contacto de emergencia | sin destino | 🔴 |
| G3 | `viveContigo` (mismo domicilio que el tutor) | sin destino | 🔴 |
| G4 | Ciudad de nacimiento (`people.birth` no tiene municipio de nacimiento) | destino parcial | 🔴 |
| G5 | Catálogo de **lenguas indígenas** (hoy lista estática en el front) | falta catálogo (ADR 044) | 🔴 |
| G6 | `is_primary` en teléfonos: el front distingue principal/otro y el modelo no | dato perdido | 🔴 |
| G7 | `numeroExterior` / `numeroInterior` fusionados en `address_complement` | destino parcial | 🔴 |
| G8 | `lenguaIndigena`: *"¿habla?"* (front) vs *"¿se considera?"* (modelo) | semántica | 🔴 |
| G9 | `legal_info.type_national_id_sex` vs `biological_profile.type_biological_sex` (¿mismo dato?) | duplicidad | 🔴 |
| G10 | El correo de la cuenta: ¿solo `auth.user.username` o también `people.email`? | duplicidad | 🔴 |
| G11 | El OTP: `dh_mfa.otp_challenges` (Mongo) y `mfa.otp_challenge` (PG) | duplicidad | 🔴 |

> `discapacidad` (antes G1) quedó **resuelta** ✓: `health_profile.person_disability`
> (enum `EDisabilityType`; si el vocabulario crece, pasa a catálogo y esta tabla
> queda como intermedia — ver el comentario en el ERD de `health_profile` ✓).

## Campos del modelo (o de la HC) que el signup **no** captura

`profile.known_as` · `profile.about_me` · `sociocultural_identity.self_considers_migrant` ·
`key_country_origin` · `legal_info.key_nationality` · `social_links` · `photo` ·
`emergency_contact.email` / `notes` · `profile.income_range` y *"dependientes"*
(la HC los pide en 1.2.18–1.2.19: `EIncomeRange` está en **rangos de $** mientras la
HC pregunta por **suficiencia** — desalineado 🔴) · `profile.id_occupation` de la
persona asociada.
