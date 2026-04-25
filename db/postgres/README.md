# PostgreSQL Schemas

Cada carpeta representa un schema de PostgreSQL.

| Schema | Descripcion |
|--------|-------------|
| auth | Autenticacion y sesiones |
| care | Relaciones de cuidado (responsable/cuidado) |
| catalog | Catalogos (paises, estados, municipios, colonias, idiomas, religiones, etc) |
| expedient | Documentos e identificadores |
| health_profile | Perfil biologico y clinico (sexo biologico, tipo de sangre, alergias, condiciones cronicas) |
| iam | Control de acceso, roles y permisos |
| mfa | Autenticacion multifactor (TOTP, SMS, email, recovery codes) |
| people | Datos demograficos y contacto |
| public | Tablas publicas sin schema especifico |

## Dependencias entre schemas

La tabla `person` (schema `people`) es la entidad central del sistema. Los siguientes schemas la referencian como FK:

| Schema | Tablas que referencian `people.person` |
|--------|----------------------------------------|
| auth | `user`, `device`, `session`, `login_attempt`, `password_reset` (id_person) |
| care | `person_responsible` (id_dependent, id_responsible) |
| expedient | `document` (id_person) |
| health_profile | `biological_profile`, `person_allergy`, `chronic_condition`, `vaccination_record` (id_person) |
| iam | `membership` (id_person) |
| mfa | `auth_factor`, `otp_challenge`, `recovery_code` (id_person) |

## Convenciones

- Cada carpeta = 1 schema de PostgreSQL
- `erd.mmd` = Diagrama ERD (tablas)
- `views.sql` = Vistas del schema (futuro)
- Enums como bloques standalone con prefijo `E`
- Referencias a tablas de otros schemas se documentan con comentarios `%%` en el ERD, no se duplican bloques
- Todas las entidades (excepto intermediarias N:N puras) heredan de `BaseModel` (`id`, `created_at`, `updated_at`, `deleted_at`). Estas columnas no se repiten en los ERDs.