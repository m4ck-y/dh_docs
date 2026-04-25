# people

Schema de PostgreSQL para datos demográficos y de contacto de personas.

Es el schema central del sistema: toda entidad que represente a una persona física (usuario, tutor, colaborador) tiene una fila en `person`.

## Entidades

| Entidad | Descripción |
|---|---|
| `person` | Tabla central — nombre, foto, género, estado de verificación |
| `user` | Cuenta de acceso al sistema (1:1 con `person`) |
| `birth` | Fecha y lugar de nacimiento |
| `email` | Correos electrónicos (múltiples por persona) |
| `phone` | Teléfonos de contacto (múltiples por persona) |
| `address` | Domicilios (múltiples por persona, con claves geográficas al catálogo) |
| `profile` | Perfil laboral/profesional — ocupación, apodo, descripción |
| `sociocultural_identity` | Identidad sociocultural — religión, idioma indígena, migración |
| `legal_info` | Información legal — nacionalidad, estado civil, sexo en ID oficial |
| `personal_identifier` | Identificadores oficiales — CURP, RFC, NSS, etc. |
| `identifier_type` | Catálogo de tipos de identificador |
| `emergency_contact` | Contactos de emergencia con tipo de relación |
| `social_links` | Perfiles en redes sociales |
| `social_platform` | Catálogo de plataformas sociales |

## Enums

| Enum | Valores relevantes |
|---|---|
| `EVerificationStatus` | `PENDING`, `APPROVED`, `REJECTED` |
| `EGenderIdentity` | `NO_ESPECIFICADO`, `MASCULINO`, `FEMENINO`, `TRANSGENERO`, `TRANSEXUAL`, `TRAVESTI`, `INTERSEXUAL`, `OTRO` |
| `EEducationLevel` | `NO_STUDIES`, `PRIMARY`, `SECONDARY`, `HIGH_SCHOOL`, `UNIVERSITY`, `POSTGRADUATE`, `PREFERS_NOT_TO_SAY` |
| `EIncomeRange` | `NO_INCOME`, `UNDER_5000`, `FROM_5000_TO_9999`, `FROM_10000_TO_19999`, `FROM_20000_TO_39999`, `FROM_40000`, `PREFERS_NOT_TO_SAY` |
| `ESocialPlatform` | `TWITTER`, `LINKEDIN`, `GITHUB`, `FACEBOOK`, `INSTAGRAM`, `YOUTUBE`, `TIKTOK`, `PERSONAL_WEBSITE`, `OTHER` |
| `EIdentifierType` | `NATIONAL_ID`, `FISCAL_ID`, `SOCIAL_SECURITY_ID` |
| `EAddressType` | `HOME`, `WORK`, `BUSINESS`, `OTHER` |
| `EEmailType` | `PERSONAL`, `WORK`, `BUSINESS`, `OTHER` |
| `EPhoneType` | `MOBILE`, `WORK`, `HOME`, `BUSINESS`, `OTHER` |
| `ERelationshipContact` | `SPOUSE`, `PARENT`, `SIBLING`, `CHILD`, `FRIEND`, `CAREGIVER`, `OTHER` |
| `EOccupationType` | `EMPLOYED`, `SELF_EMPLOYED`, `FREELANCE`, `HOMEMAKER`, `UNEMPLOYED`, `RETIRED`, `OTHER`, `PREFERS_NOT_TO_SAY` |
| `ECivilStatus` | `SINGLE`, `MARRIED`, `COMMON_LAW`, `SEPARATED`, `DIVORCED`, `WIDOWED`, `PREFERS_NOT_TO_SAY` |

## Archivos

| Archivo | Descripción |
|---|---|
| [erd.mmd](./erd.mmd) | Diagrama ERD del schema en Mermaid |
