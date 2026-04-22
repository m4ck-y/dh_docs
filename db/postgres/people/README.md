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
| `EGenderIdentity` | `NO_ESPECIFICADO`, `MASCULINO`, `FEMENINO`, `TRANSGENERO`, `TRANSEXUAL`, `TRAVESTI`, `INTERSEXUAL`, `OTRO` |
| `EPhoneType` | `MOBILE`, `WORK`, `HOME`, `BUSINESS`, `OTHER` |
| `EEmailType` | `PERSONAL`, `WORK`, `BUSINESS`, `OTHER` |
| `EAddressType` | `HOME`, `WORK`, `BUSINESS`, `OTHER` |
| `ERelationshipContact` | `SPOUSE`, `PARENT`, `SIBLING`, `CHILD`, `FRIEND`, `OTHER` |
| `EIdentifierType` | `NATIONAL_ID`, `FISCAL_ID`, `SOCIAL_SECURITY_ID` |
| `EVerificationStatus` | `PENDING`, `APPROVED`, `REJECTED` |

## Archivos

| Archivo | Descripción |
|---|---|
| [erd.mmd](./erd.mmd) | Diagrama ERD del schema en Mermaid |
