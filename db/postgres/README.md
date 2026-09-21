# PostgreSQL Schemas

Cada carpeta representa un schema de PostgreSQL.

| Schema | Descripcion |
|--------|-------------|
| auth | Autenticacion y sesiones |
| relationships | Vinculos entre personas (familia, pareja, cuidado) |
| catalog | Catalogos gobernados (vocabularios controlados extensibles; owner dh_catalogs) |
| clinical_history | Historial clinico con trazabilidad temporal (condiciones/enfermedades) |
| form | Cuestionarios (catalogo de definicion y ejecucion) |
| storage | Documentos e identificadores (antes expedient) |
| health_profile | Perfil biologico y clinico (sexo biologico, tipo de sangre, alergias, fallecimiento) |
| iam | Control de acceso, roles y permisos |
| mfa | Autenticacion multifactor (TOTP, SMS, email, recovery codes) |
| organizations | Estructura corporativa, ubicaciones y empleados |
| people | Datos demograficos y contacto |
| public | Tablas publicas sin schema especifico |

## Dependencias entre schemas

La tabla `person` (schema `people`) es la entidad central del sistema. Los siguientes schemas la referencian como FK:

| Schema | Tablas que referencian `people.person` |
|--------|----------------------------------------|
| auth | `user`, `device`, `session`, `login_attempt`, `password_reset` (id_person) |
| relationships | `person_responsible`, `family`, `partnership` (id_person) |
| storage | `document` (id_person) |
| health_profile | `biological_profile`, `person_allergy`, `vaccination_record`, `death` (id_person) |
| clinical_history | `condition`, `medication_statement`, `medication_condition` (id_person) |
| iam | `membership` (id_person) |
| mfa | `auth_factor`, `otp_challenge`, `recovery_code` (id_person) |
| form | `assignment` (id_person). Nota: `answer.answered_by` referencia la entidad de usuarios (auth/iam), no `people.person`. |

## Convenciones

- Cada carpeta = 1 schema de PostgreSQL
- `erd.mmd` = Diagrama ERD (tablas)
- `views.sql` = Vistas del schema (futuro)
- Enums como bloques standalone con prefijo `E`
- Referencias a tablas de otros schemas se documentan con comentarios `%%` en el ERD, no se duplican bloques
- Todas las entidades (excepto intermediarias N:N puras) heredan de `BaseModel` (`id`, `created_at`, `updated_at`, `deleted_at`). Estas columnas no se repiten en los ERDs.