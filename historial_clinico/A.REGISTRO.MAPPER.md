# A. REGISTRO — Mapper DB

> **Convención:**
> - 🟢 `schema.entidad.columna` — campo ya modelado en la DB
> - 🟡 `schema.entidad` — entidad existe pero falta columna específica
> - 🔴 — no existe en la DB aún

---

## 1.0 ¿Requiere apoyo de tutor o responsable? _(pregunta condicional)_

🟢 `care.person_responsible` — la existencia de un registro implica "sí requiere tutor"

---

## Ruta 1.1 — Sí (con tutor/responsable)

> _"A continuación, ingrese los datos del tutor o responsable."_

### Datos del tutor / responsable

El tutor es una `person` en la DB. Sus datos se recogen igual que los del usuario.

- **1.1.1 Nombre completo** _(Apellido Paterno, Apellido Materno, Nombre(s))_
  - 🟢 `people.person.first_name`
  - 🟢 `people.person.last_name`
  - 🟢 `people.person.second_last_name`

- **1.1.2 Parentesco** _(condicional)_
  - 1.1.2.1 Madre → 🟢 `care.person_responsible.type_relationship` = `MOTHER`
  - 1.1.2.2 Padre → 🟢 `care.person_responsible.type_relationship` = `FATHER`
  - 1.1.2.3 Cuidador(a) → 🟢 `care.person_responsible.type_relationship` = `CAREGIVER`
  - 1.1.2.4 Tutor legal → 🟢 `care.person_responsible.type_relationship` = `LEGAL_GUARDIAN`
  - 1.1.2.6 Otro → 🟢 `care.person_responsible.type_relationship` = `OTHER`
    - 1.1.2.6.1 _Especifique_ → 🟢 `care.person_responsible.relationship_other`

- **1.1.3 ¿Cuál es su relación en el cuidado y vida diaria del paciente?** _(condicional)_
  - 1.1.3.1 Vive con el usuario y participa en su cuidado → 🟢 `care.person_responsible.care_role` = `LIVES_WITH_AND_CARES`
  - 1.1.3.2 Participa en su cuidado, pero no vive con él/ella → 🟢 `care.person_responsible.care_role` = `CARES_NOT_LIVING_WITH`
  - 1.1.3.3 Sólo brinda apoyo administrativo o legal → 🟢 `care.person_responsible.care_role` = `ADMINISTRATIVE_SUPPORT_ONLY`

---

> _"A continuación, comparta algunos datos generales que nos ayudarán a conocer mejor su entorno."_

### Datos del usuario (recopilados por el tutor)

- **1.1.4 Domicilio actual** _(Calle, Manzana/Lote o # Ext., # Int., Unidad, Colonia, Ciudad, Entidad, CP.)_
  - 🟢 `people.address.address` — calle + número
  - 🟢 `people.address.address_complement` — # int., unidad
  - 🟢 `people.address.key_colony` → catálogo colonia
  - 🟢 `people.address.key_municipality` → catálogo municipio/ciudad
  - 🟢 `people.address.key_state` → catálogo entidad federativa
  - 🟢 `people.address.key_country` → catálogo país
  - 🟢 `people.address.postal_code`
  - 🟢 `people.address.type_address` = `HOME`

- **1.1.5 Fecha de nacimiento** _(dd, mmm, aaaa)_
  - 🟢 `people.birth.birth_date`

- **1.1.6 Lugar de nacimiento** _(Ciudad, Edo)_
  - 🟢 `people.birth.key_state_birth`
  - 🟢 `people.birth.key_birth_country`

- **1.1.7 Teléfono fijo**
  - 🟢 `people.phone.code` + `people.phone.number` con `type_phone` = `HOME`

- **1.1.8 Celular**
  - 🟢 `people.phone.code` + `people.phone.number` con `type_phone` = `MOBILE`

- **1.1.9 Correo electrónico**
  - 🟢 `people.email.email` con `type_email` = `PERSONAL`

- **1.1.10 Sexo al nacer** _(condicional)_
  - 1.1.10.1 Femenino → 🟢 `health_profile.biological_profile.type_biological_sex` = `MUJER`
  - 1.1.10.2 Masculino → 🟢 `health_profile.biological_profile.type_biological_sex` = `HOMBRE`
  - 1.1.10.3 Intersexual → 🟢 `health_profile.biological_profile.type_biological_sex` = `INTERSEXUAL`
  - 1.1.10.4 Prefiere no decirlo → 🟢 `health_profile.biological_profile.type_biological_sex` = `NULL`

- **1.1.11 Edad**
  - 🟢 calculada desde `people.birth.birth_date` (no se almacena)

- **1.1.12 Religión** _(condicional)_
  - 1.1.12.1 Católica → 🟡 `people.sociocultural_identity.key_religion` — existe la FK al catálogo
  - 1.1.12.2 Cristiana → 🟡 `people.sociocultural_identity.key_religion`
  - 1.1.12.3 Otra religión → 🟡 `people.sociocultural_identity.key_religion`
    - 1.1.12.3.1 _Especifique_ → 🟢 `people.sociocultural_identity.religion_other`
  - 1.1.12.4 Ninguna → 🟡 `people.sociocultural_identity.key_religion` — depende del catálogo
  - 1.1.12.5 Prefiere no decirlo → 🟢 `people.sociocultural_identity.key_religion` = `NULL`

- **1.1.13 Escolaridad**
  - 1.1.13.1 Sin estudios → 🟢 `people.profile.education_level` = `NO_STUDIES`
  - 1.1.13.2 Educación primaria → 🟢 `people.profile.education_level` = `PRIMARY`
  - 1.1.13.3 Educación secundaria → 🟢 `people.profile.education_level` = `SECONDARY`
  - 1.1.13.4 Educación media superior → 🟢 `people.profile.education_level` = `HIGH_SCHOOL`
  - 1.1.13.5 Educación superior → 🟢 `people.profile.education_level` = `UNIVERSITY`
  - 1.1.13.6 Posgrado → 🟢 `people.profile.education_level` = `POSTGRADUATE`
  - 1.1.13.6 Prefiere no decirlo → 🟢 `people.profile.education_level` = `PREFERS_NOT_TO_SAY`

- **1.1.14 Estado civil** _(condicional)_
  - 1.1.14.1 Soltero/a → 🟢 `people.legal_info.civil_status` = `SINGLE`
  - 1.1.14.2 Casado/a → 🟢 `people.legal_info.civil_status` = `MARRIED`
  - 1.1.14.3 Unión libre / convivencia → 🟢 `people.legal_info.civil_status` = `COMMON_LAW`
  - 1.1.14.4 Separado/a → 🟢 `people.legal_info.civil_status` = `SEPARATED`
  - 1.1.14.5 Divorciado/a → 🟢 `people.legal_info.civil_status` = `DIVORCED`
  - 1.1.14.6 Viudo/a → 🟢 `people.legal_info.civil_status` = `WIDOWED`
  - 1.1.14.7 Prefiere no decirlo → 🟢 `people.legal_info.civil_status` = `NULL`

- **1.1.17 ¿El usuario depende económicamente de usted?**
  - 1.1.17.1 Sí → 🟢 `care.person_responsible.economic_dependence` = `YES`
  - 1.1.17.2 Parcialmente → 🟢 `care.person_responsible.economic_dependence` = `PARTIALLY`
  - 1.1.17.3 No → 🟢 `care.person_responsible.economic_dependence` = `NO`

- **1.1.15 Ocupación**
  - 1.1.15.1 Empleado/a → 🟢 `people.profile.occupation_type` = `EMPLOYED`
  - 1.1.15.2 Trabajador/a independiente → 🟢 `people.profile.occupation_type` = `SELF_EMPLOYED`
  - 1.1.15.3 Trabajador/a independiente ⚠️ _(duplicado en diagrama)_ → 🟢 `people.profile.occupation_type` = `FREELANCE`
  - 1.1.15.4 Trabajo del hogar → 🟢 `people.profile.occupation_type` = `HOMEMAKER`
  - 1.1.15.5 Desempleado/a → 🟢 `people.profile.occupation_type` = `UNEMPLOYED`
  - 1.1.15.6 Jubilado/a o pensionado/a → 🟢 `people.profile.occupation_type` = `RETIRED`
  - 1.1.15.7 Otro → 🟢 `people.profile.occupation_type` = `OTHER`
    - _(Especifique)_ → 🟢 `people.profile.occupation_other`
  - 1.1.15.8 Prefiere no decirlo → 🟢 `people.profile.occupation_type` = `PREFERS_NOT_TO_SAY`

- **1.1.16 Ingresos**
  - 1.1.16.1 Sin ingresos → 🟢 `people.profile.income_range` = `NO_INCOME`
  - 1.1.16.2 < $5,000 → 🟢 `people.profile.income_range` = `UNDER_5000`
  - 1.1.16.3 $5,000 – $9,999 → 🟢 `people.profile.income_range` = `FROM_5000_TO_9999`
  - 1.1.16.4 $10,000 – $19,999 → 🟢 `people.profile.income_range` = `FROM_10000_TO_19999`
  - 1.1.16.5 $20,000 – $39,999 → 🟢 `people.profile.income_range` = `FROM_20000_TO_39999`
  - 1.1.16.6 ≥ $40,000 → 🟢 `people.profile.income_range` = `FROM_40000`
  - 1.1.16.7 Prefiere no decirlo → 🟢 `people.profile.income_range` = `PREFERS_NOT_TO_SAY`

---

## Ruta 1.2 — No (sin tutor)

_(El usuario llena sus propios datos. Mismos campos y mapeos que los de la sección 1.1, aplicados directamente a la `person` del usuario.)_

---

## Datos generales del usuario _(persona en seguimiento)_

- **1.2.1 Nombre completo**
  - 🟢 `people.person.first_name`
  - 🟢 `people.person.last_name`
  - 🟢 `people.person.second_last_name`

- **1.2.2 Domicilio actual**
  - 🟢 `people.address.*` (ver desglose en 1.1.4)

- **1.2.3 Fecha de nacimiento**
  - 🟢 `people.birth.birth_date`

- **1.2.4 Lugar de nacimiento**
  - 🟢 `people.birth.key_state_birth`
  - 🟢 `people.birth.key_birth_country`

- **1.2.5 Teléfono fijo**
  - 🟢 `people.phone` con `type_phone` = `HOME`

- **1.2.6 Celular**
  - 🟢 `people.phone` con `type_phone` = `MOBILE`

- **1.2.7 Correo electrónico**
  - 🟢 `people.email.email` con `type_email` = `PERSONAL`

### Contacto de emergencia _(opcional)_

- **1.2.8B Nombre completo del contacto**
  - 🟢 `people.emergency_contact.first_name`
  - 🟢 `people.emergency_contact.last_name`

- **1.2.9 Parentesco** _(condicional)_
  - 1.2.9.1 Madre → 🟡 `people.emergency_contact.relationship_type` — `ERelationshipContact` tiene `PARENT`, no diferencia madre/padre
  - 1.2.9.2 Padre → 🟡 `people.emergency_contact.relationship_type` = `PARENT`
  - 1.2.9.3 Pareja → 🟢 `people.emergency_contact.relationship_type` = `SPOUSE`
  - 1.2.9.4 Hermano(a) → 🟢 `people.emergency_contact.relationship_type` = `SIBLING`
  - 1.2.9.5 Hijo(a) → 🟢 `people.emergency_contact.relationship_type` = `CHILD`
  - 1.2.9.6 Amigo(a) → 🟢 `people.emergency_contact.relationship_type` = `FRIEND`
  - 1.2.9.7 Cuidador(a) → 🟢 `people.emergency_contact.relationship_type` = `CAREGIVER`
  - 1.2.9.4 Otro → 🟢 `people.emergency_contact.relationship_type` = `OTHER`
    - 1.2.9.1.1 _Especifique_ → 🟢 `people.emergency_contact.relationship_other`

- **1.2.10 Teléfono principal del contacto**
  - 🟢 `people.emergency_contact.phone_number`

### Más datos del usuario

- **1.2.11 Sexo al nacer**
  - 1.2.11.1 Mujer → 🟢 `health_profile.biological_profile.type_biological_sex` = `MUJER`
  - 1.2.11.2 Hombre → 🟢 `health_profile.biological_profile.type_biological_sex` = `HOMBRE`
  - 1.2.11.3 Intersexual → 🟢 `health_profile.biological_profile.type_biological_sex` = `INTERSEXUAL`
  - 1.2.11.4 Prefiere no decirlo → 🟢 `health_profile.biological_profile.type_biological_sex` = `NULL`

- **1.2.13 Edad**
  - 🟢 calculada desde `people.birth.birth_date`

- **1.2.14 Religión** _(condicional)_
  - 1.2.14.1 Católica → 🟡 `people.sociocultural_identity.key_religion` — depende del catálogo
  - 1.2.14.2 Cristiana → 🟡 `people.sociocultural_identity.key_religion`
  - 1.2.14.3 Otra religión → 🟡 `people.sociocultural_identity.key_religion`
    - _Especifique_ → 🟢 `people.sociocultural_identity.religion_other`
  - 1.2.14.4 Ninguna → 🟡 `people.sociocultural_identity.key_religion` — depende del catálogo
  - 1.2.14.5 Prefiere no decirlo → 🟢 `people.sociocultural_identity.key_religion` = `NULL`

- **1.2.16 Estado civil**
  - 1.2.16.1 Soltero/a → 🟢 `people.legal_info.civil_status` = `SINGLE`
  - 1.2.16.2 Casado/a → 🟢 `people.legal_info.civil_status` = `MARRIED`
  - 1.2.16.3 Unión libre / convivencia → 🟢 `people.legal_info.civil_status` = `COMMON_LAW`
  - 1.2.16.4 Separado/a → 🟢 `people.legal_info.civil_status` = `SEPARATED`
  - 1.2.16.5 Divorciado/a → 🟢 `people.legal_info.civil_status` = `DIVORCED`
  - 1.2.16.6 Viudo/a → 🟢 `people.legal_info.civil_status` = `WIDOWED`
  - 1.2.16.7 Prefiere no decirlo → 🟢 `people.legal_info.civil_status` = `NULL`

---

## Resumen de gaps 🟡

| Campo | Entidad | Nota |
|---|---|---|
| Religión (1.1.12 / 1.2.14) | `people.sociocultural_identity.key_religion` | FK a catálogo `catalog.religion` — catálogo pendiente de poblar |
